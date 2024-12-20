import subprocess
import json

def get_allocated_resources():
    # Fetch all nodes information in JSON format using 'oc' command
    nodes_output = subprocess.check_output(['oc', 'get', 'nodes', '-o', 'json'])
    nodes_data = json.loads(nodes_output)  # Parse JSON output

    # Initialize an empty list to store the results
    results = []

    # Fetch all pods across all namespaces in JSON format
    pods_output = subprocess.check_output(['oc', 'get', 'pods', '--all-namespaces', '-o', 'json'])
    pods_data = json.loads(pods_output)  # Parse JSON output

    # Iterate through each node
    for node in nodes_data['items']:
        node_name = node['metadata']['name']  # Get the node's name

        # Skip nodes that do not have "regionalizacao-hlg" in their name
        if "regionalizacao-hlg" not in node_name:
            continue

        # Extract allocatable CPU and memory from the node's status
        allocatable_cpu = node['status']['allocatable'].get('cpu', '0')
        allocatable_memory = node['status']['allocatable'].get('memory', '0')

        # Convert allocatable CPU from cores/millicores to millicores
        if allocatable_cpu.endswith('m'):  # CPU is already in millicores
            allocatable_cpu_millicores = int(allocatable_cpu[:-1])
        elif allocatable_cpu.isdigit():  # CPU is in cores, convert to millicores
            allocatable_cpu_millicores = int(allocatable_cpu) * 1000
        else:  # Default to 0 if format is unrecognized
            allocatable_cpu_millicores = 0

        # Convert allocatable memory from various units to MiB
        if allocatable_memory.endswith('Mi'):  # Memory in MiB
            allocatable_memory_mib = int(allocatable_memory[:-2])
        elif allocatable_memory.endswith('Gi'):  # Memory in GiB
            allocatable_memory_mib = int(allocatable_memory[:-2]) * 1024
        elif allocatable_memory.endswith('Ki'):  # Memory in KiB
            allocatable_memory_mib = int(allocatable_memory[:-2]) // 1024
        elif allocatable_memory.isdigit():  # Memory in raw bytes
            allocatable_memory_mib = int(allocatable_memory) // (1024 * 1024)
        else:  # Default to 0 if format is unrecognized
            allocatable_memory_mib = 0

        # Initialize variables for tracking allocated resources
        allocated_cpu_requests = 0
        allocated_memory_requests = 0
        allocated_cpu_limits = 0
        allocated_memory_limits = 0

        # Iterate through all pods to calculate resource usage
        for pod in pods_data['items']:
            # Skip pods that are not in the "Running" state
            if pod['status']['phase'] != 'Running':
                continue

            # Check if the pod is scheduled on the current node
            if pod['spec'].get('nodeName') == node_name:
                # Iterate through all containers in the pod
                for container in pod['spec']['containers']:
                    resources = container.get('resources', {})  # Get container resources

                    # Requests: Minimum guaranteed resources for the container
                    requests = resources.get('requests', {})
                    cpu_request = requests.get('cpu', '0')
                    memory_request = requests.get('memory', '0')

                    # Limits: Maximum resources the container can use
                    limits = resources.get('limits', {})
                    cpu_limit = limits.get('cpu', '0')
                    memory_limit = limits.get('memory', '0')

                    # Convert CPU requests from cores/millicores to millicores
                    if cpu_request.endswith('m'):
                        allocated_cpu_requests += int(cpu_request[:-1])
                    elif cpu_request.isdigit():
                        allocated_cpu_requests += int(cpu_request) * 1000  # Convert cores to millicores

                    # Convert memory requests to MiB
                    if memory_request.endswith('Mi'):
                        allocated_memory_requests += int(memory_request[:-2])
                    elif memory_request.endswith('Gi'):
                        allocated_memory_requests += int(memory_request[:-2]) * 1024

                    # Convert CPU limits from cores/millicores to millicores
                    if cpu_limit.endswith('m'):
                        allocated_cpu_limits += int(cpu_limit[:-1])
                    elif cpu_limit.isdigit():
                        allocated_cpu_limits += int(cpu_limit) * 1000  # Convert cores to millicores

                    # Convert memory limits to MiB
                    if memory_limit.endswith('Mi'):
                        allocated_memory_limits += int(memory_limit[:-2])
                    elif memory_limit.endswith('Gi'):
                        allocated_memory_limits += int(memory_limit[:-2]) * 1024

        # Calculate resource usage percentages
        cpu_requests_percentage = (allocated_cpu_requests / allocatable_cpu_millicores * 100) if allocatable_cpu_millicores > 0 else 0
        memory_requests_percentage = (allocated_memory_requests / allocatable_memory_mib * 100) if allocatable_memory_mib > 0 else 0
        cpu_limits_percentage = (allocated_cpu_limits / allocatable_cpu_millicores * 100) if allocatable_cpu_millicores > 0 else 0
        memory_limits_percentage = (allocated_memory_limits / allocatable_memory_mib * 100) if allocatable_memory_mib > 0 else 0

        # Append the node's resource usage data to results
        results.append({
            'node': node_name,
            'allocated_cpu_requests_millicores': allocated_cpu_requests,
            'allocated_memory_requests_mib': allocated_memory_requests,
            'allocated_cpu_limits_millicores': allocated_cpu_limits,
            'allocated_memory_limits_mib': allocated_memory_limits,
            'cpu_requests_percentage': cpu_requests_percentage,
            'memory_requests_percentage': memory_requests_percentage,
            'cpu_limits_percentage': cpu_limits_percentage,
            'memory_limits_percentage': memory_limits_percentage
        })

    # Return the results as a list of dictionaries
    return results

# Run the function and print results
resources = get_allocated_resources()
for resource in resources:
    print(f"Node: {resource['node']}, CPU Requests: {resource['allocated_cpu_requests_millicores']}m ({resource['cpu_requests_percentage']:.2f}%), "
          f"Memory Requests: {resource['allocated_memory_requests_mib']}MiB ({resource['memory_requests_percentage']:.2f}%), "
          f"CPU Limits: {resource['allocated_cpu_limits_millicores']}m ({resource['cpu_limits_percentage']:.2f}%), "
          f"Memory Limits: {resource['allocated_memory_limits_mib']}MiB ({resource['memory_limits_percentage']:.2f}%)")
