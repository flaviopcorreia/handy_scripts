import subprocess
import json

def get_allocated_resources():
    # Fetch all nodes
    nodes_output = subprocess.check_output(['kubectl', 'get', 'nodes', '-o', 'json'])
    nodes_data = json.loads(nodes_output)

    # Initialize results
    results = []

    # Fetch pods and group by node
    pods_output = subprocess.check_output(['kubectl', 'get', 'pods', '--all-namespaces', '-o', 'json'])
    pods_data = json.loads(pods_output)

    for node in nodes_data['items']:
        node_name = node['metadata']['name']

        # Filter nodes containing "tracking" in their name
        if "tracking" not in node_name:
            continue

        # Get allocatable resources
        allocatable_cpu = node['status']['allocatable'].get('cpu', '0')
        allocatable_memory = node['status']['allocatable'].get('memory', '0')

        # Convert allocatable CPU to millicores
        if allocatable_cpu.endswith('m'):
            allocatable_cpu_millicores = int(allocatable_cpu[:-1])
        elif allocatable_cpu.isdigit():
            allocatable_cpu_millicores = int(allocatable_cpu) * 1000
        else:
            allocatable_cpu_millicores = 0

        # Convert allocatable memory to MiB
        if allocatable_memory.endswith('Mi'):
            allocatable_memory_mib = int(allocatable_memory[:-2])
        elif allocatable_memory.endswith('Gi'):
            allocatable_memory_mib = int(allocatable_memory[:-2]) * 1024
        elif allocatable_memory.endswith('Ki'):
            allocatable_memory_mib = int(allocatable_memory[:-2]) // 1024  # Convert Ki to MiB
        elif allocatable_memory.isdigit():
            allocatable_memory_mib = int(allocatable_memory) // (1024 * 1024)
        else:
            allocatable_memory_mib = 0

        allocated_cpu_requests = 0
        allocated_memory_requests = 0
        allocated_cpu_limits = 0
        allocated_memory_limits = 0

        for pod in pods_data['items']:
            # Check if the pod is in a running state
            if pod['status']['phase'] != 'Running':
                continue

            if pod['spec'].get('nodeName') == node_name:
                for container in pod['spec']['containers']:
                    resources = container.get('resources', {})

                    # Requests
                    requests = resources.get('requests', {})
                    cpu_request = requests.get('cpu', '0')
                    memory_request = requests.get('memory', '0')

                    # Limits
                    limits = resources.get('limits', {})
                    cpu_limit = limits.get('cpu', '0')
                    memory_limit = limits.get('memory', '0')

                    # Convert CPU requests to millicores (m)
                    if cpu_request.endswith('m'):
                        allocated_cpu_requests += int(cpu_request[:-1])
                    elif cpu_request.isdigit():
                        allocated_cpu_requests += int(cpu_request) * 1000  # Convert cores to millicores

                    # Convert memory requests to MiB
                    # Convert memory requests to MiB
                    if memory_request.endswith('Mi'):
                        allocated_memory_requests += int(memory_request[:-2])
                    elif memory_request.endswith('Gi'):
                        allocated_memory_requests += int(memory_request[:-2]) * 1024

                    # Convert CPU limits to millicores (m)
                    if cpu_limit.endswith('m'):
                        allocated_cpu_limits += int(cpu_limit[:-1])
                    elif cpu_limit.isdigit():
                        allocated_cpu_limits += int(cpu_limit) * 1000  # Convert cores to millicores

                    # Convert memory limits to MiB
                    if memory_limit.endswith('Mi'):
                        allocated_memory_limits += int(memory_limit[:-2])
                    elif memory_limit.endswith('Gi'):
                        allocated_memory_limits += int(memory_limit[:-2]) * 1024

        # Calculate percentages
        cpu_requests_percentage = (allocated_cpu_requests / allocatable_cpu_millicores * 100) if allocatable_cpu_millicores > 0 else 0
        memory_requests_percentage = (allocated_memory_requests / allocatable_memory_mib * 100) if allocatable_memory_mib > 0 else 0
        cpu_limits_percentage = (allocated_cpu_limits / allocatable_cpu_millicores * 100) if allocatable_cpu_millicores > 0 else 0
        memory_limits_percentage = (allocated_memory_limits / allocatable_memory_mib * 100) if allocatable_memory_mib > 0 else 0

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

    return results

# Run and print results
resources = get_allocated_resources()
for resource in resources:
    print(f"Node: {resource['node']}, CPU Requests: {resource['allocated_cpu_requests_millicores']}m ({resource['cpu_requests_percentage']:.2f}%), Memory Requests: {resource['allocated_memory_requests_mib']}MiB ({resource['memory_requests_percentage']:.2f}%), CPU Limits: {resource['allocated_cpu_limits_millicores']}m ({resource['cpu_limits_percentage']:.2f}%), Memory Limits: {resource['allocated_memory_limits_mib']}MiB ({resource['memory_limits_percentage']:.2f}%)")
