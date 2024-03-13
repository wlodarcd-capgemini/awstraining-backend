[
  {
    "name": "backend-${task_definition_name}",
    "image": "${image}",
    "memoryReservation": 256,
    "memory": 512,
    "cpu": 256,
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
          "name": "INITIAL_START",
          "value": "true"
        },
        {
          "name": "STAGE",
          "value": "${environment}"
        },
        {
          "name": "AWS_REGION",
          "value": "${region}"
        },
        {
          "name": "CONFIG_BUCKET",
          "value": "${config_bucket}"
        },
        {
           "name": "DISCOVERY_FILTER",
           "value": "${discovery_filter}"
        }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "/ecs/${log_group}",
            "awslogs-region": "${region}",
            "awslogs-stream-prefix": "ecs"
        }
    }
  }
]