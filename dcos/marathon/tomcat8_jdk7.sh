curl -u dcosadmin:zjdcos01 -v -X POST http://20.26.25.188:8081/v2/apps \
    -H Content-Type:application/json -d '{
    "cmd":"sh /app/tomcat/bin/startup.sh",
    "id":"/tomcat/tomcat8-jdk7",
    "container": 
    {
    "type": "DOCKER",
    "docker":
        {
            "image": "20.26.25.10:5000/tomcat8_jdk7:latest",
            "network": "BRIDGE",
            "portMappings": 
            [
                {
                    "containerPort": 8080, "hostPort": 0, "protocol": "tcp"
                }
            ],
            "privileged": false,
            "forcePullImage": false,
            "parameters": 
            [
                {
                    "key": "user",
                    "value": "dcos"
                },
                {
                    "key":  "cpu-quota",
                    "value": "150000"
                }
            ]
        },
        "volumes": 
        [
            {
                "containerPath": "/app/app/",
                 "hostPath": "/data/dcos/tomcat/",
                 "mode": "RW"
            },
            {
                 "containerPath": "/app/logs",
                 "hostPath": "/data/logs/tomcat",
                "mode": "RW"
            }
        ]
    },
    "env": 
        {
            "TZ": "Asia/Shanghai",
            "JAVA_HOME": "/app/jdk"
        },
    "cpus": 0.5,
    "mem": 2500.0,
    "disk": 3000,
    "instances": 0,
    "constraints": [["hostname", "CLUSTER", "20.26.25.188"]],
    "healthChecks": 
        [
            {
                "portIndex": 0,
                "protocol": "TCP",
                "gracePeriodSeconds": 300,
                "intervalSeconds": 60,
                "timeoutSeconds": 30,
                "maxConsecutiveFailures": 3
            }
        ], 
    "upgradeStrategy": 
        {
            "minimumHealthCapacity": 0.5,
            "maximumOverCapacity": 0.2
        }
    }'