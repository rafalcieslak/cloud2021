Utworzenie serwisu:
```
aws ecs create-service --cluster <CLUSTER_NAME> --service-name <SERVICE_NAME>
```

Rejestracja task definition w AWSie:
```
aws ecs register-task-definition --region <AWS_REGION> --cli-input-json file://task_def_example.json
```

[Deployment] Update serwisu do najnowszej dostępnej wersji task definition:
```
aws ecs update-service --region <AWS_REGION> --cluster <CLUSTER_NAME> --service <SERVICE_NAME> --task-definition example-site
```


[Rollback] Update serwisu do wybranej wersji task definition:

```
aws ecs update-service --region <AWS_REGION> --cluster <CLUSTER_NAME> --service <SERVICE_NAME> --task-definition example-site:123
```

Oczekiwanie aż serwis osiągnie stabilny stan:
```
aws ecs wait services-stable --region <AWS_REGION> --cluster <CLUSTER_NAME> --service <SERVICE_NAME>
```

