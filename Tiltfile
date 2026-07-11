# -*- mode: Python -*-
load('ext://namespace', 'namespace_create', 'namespace_inject')
load('ext://configmap', 'configmap_from_dict')

TARGET_ARCH = 'arm64'

ENV = 'local'
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
AWS_ACCESS_KEY_ID = os.getenv('AWS_ACCESS_KEY_ID', '')
AWS_SECRET_ACCESS_KEY = os.getenv('AWS_SECRET_ACCESS_KEY', '')
AWS_REGION = os.getenv('AWS_REGION', 'us-east-1')

TALENT_KB_BEDROCK_MODEL_ARN = os.getenv('TALENT_KB_BEDROCK_MODEL_ARN', '')
TALENT_KB_SSM_KB_ID_PATH = os.getenv('TALENT_KB_SSM_KB_ID_PATH', '')

namespace = 'talent-kb-mcp-server'
namespace_create(namespace)

shared_config_map_data = {
    'LOG_LEVEL': LOG_LEVEL,
    'ENV': ENV,
    'AWS_ACCESS_KEY_ID': AWS_ACCESS_KEY_ID,
    'AWS_SECRET_ACCESS_KEY': AWS_SECRET_ACCESS_KEY,
    'AWS_REGION': AWS_REGION,
    'TALENT_KB_BEDROCK_MODEL_ARN': TALENT_KB_BEDROCK_MODEL_ARN,
    'TALENT_KB_SSM_KB_ID_PATH': TALENT_KB_SSM_KB_ID_PATH,
}


talent_configmap = configmap_from_dict('shared-config', inputs=shared_config_map_data)
k8s_yaml(namespace_inject(talent_configmap, namespace))

k8s_yaml(namespace_inject(kustomize('infra-as-code/k8s/tilt'), namespace))

# Talent KB server — port 8000
docker_build('talent-kb-mcp-server', './backend',
    dockerfile='./backend/mcp-servers/talent-kb/Dockerfile',
    target='localdev',
    live_update=[
        sync('./backend/mcp-servers/talent-kb/src', '/workspace'),
    ], build_args={
        'TARGET_ARCH': TARGET_ARCH,
    })

k8s_resource('talent-kb-mcp-server', port_forwards='8000:8000')
