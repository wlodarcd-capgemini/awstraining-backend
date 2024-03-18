[
  {
    "name": "prometheus",
    "image": "${ecr_url}:prometheus",
    "memoryReservation": 512,
    "memory": 1024,
    "cpu": 512,
    "essential": true,
    "portMappings": [
        {
        "containerPort": 9090,
        "hostPort": 9090,
        "protocol": "tcp"
        }
    ],
    "environment": [
        {
          "name": "ELASTICSEARCH_URL",
          "value": "${elasticsearch_url}"
        },
        {
           "name": "DISCOVERY_FILTER",
           "value": "application=backend"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "DockerLabels": {
        "application": "kibana"
    }
  }
]