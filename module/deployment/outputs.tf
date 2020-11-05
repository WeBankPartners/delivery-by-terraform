output "deployment_step_ids" {
  value = concat([
      for step in null_resource.db_deployments : step.id
    ],[
      for step in null_resource.app_deployments : step.id
    ],[
      for step in null_resource.post_deployment_steps : step.id
    ]
  )
}
