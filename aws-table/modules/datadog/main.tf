data "local_file" "config" {
  filename = "${path.module}/../../../states.config.yaml"
}

locals {
  config               = yamldecode(data.local_file.config.content)
  widgets_per_row      = 3
  intermediate_indexes = length(local.config.states.intermediate) >0 ? zipmap(range(length(local.config.states.intermediate)), local.config.states.intermediate) : tomap({})  
 final_indexes = length(local.config.states.final) >0 ? zipmap(range(length(local.config.states.final)), local.config.states.final) : tomap({})  
 error_indexes = length(local.config.states.error) >0 ? zipmap(range(length(local.config.states.error)), local.config.states.error) : tomap({}) 
}

resource "datadog_dashboard" "sentinel_dashboard" {
  title       = "Maquinas de Estado - ${local.config.name}"
  layout_type = "free"
  description = "Criado via Terraform"

  dynamic "widget" {
    for_each = [local.config.states.inicial]
    content {
      query_value_definition {
        title       = widget.value.name
        title_size  = "16"
        title_align = "left"
        autoscale   = true
        precision   = 0
        request {
          query {
            metric_query {
              data_source = "metrics"
              name        = widget.value.code
              query       = "sum:sentinel.state.${lower(widget.value.code)}.count{*}"
              aggregator  = "sum"
            }
          }
        }
      }

      widget_layout {
        x      = 0
        y      = 0
        width  = 3
        height = 2
      }
    }

  }

  dynamic "widget" {
    for_each = length(local.intermediate_indexes) >0 ? local.intermediate_indexes : tomap({})  
    content {
      query_value_definition {
        title       = each.value.name
        title_size  = "16"
        title_align = "left"
        autoscale   = true
        precision   = 0
        request {
          query {
            metric_query {
              data_source = "metrics"
              name        = each.value.code
              query       = "sum:sentinel.state.${lower(each.value.code)}.count{*}"
              aggregator  = "sum"
            }
          }
        }
      }

      widget_layout {
        x      = (each.key % local.widgets_per_row) * 3
        y      = floor(each.key / local.widgets_per_row) * 2
        width  = 3
        height = 2
      }
    }

  }

  dynamic "widget" {
    for_each = length(local.final_indexes) >0 ? local.final_indexes : tomap({})  
    content {
      group_definition {
        title       = "Estados Finais"
        layout_type = "ordered"

        dynamic "widget" {
          for_each = length(local.final_indexes) >0 ? local.final_indexes : tomap({})  
          content {
            query_value_definition {
              title       = each.value.name
              title_size  = "16"
              title_align = "left"
              autoscale   = true
              precision   = 0
              request {
                query {
                  metric_query {
                    data_source = "metrics"
                    name        = each.value.code
                    query       = "sum:sentinel.state.${lower(each.value.code)}.count{*}"
                    aggregator  = "sum"
                  }
                }
              }
            }
          }
        }
      }
      widget_layout {
        x      = (each.key % local.widgets_per_row) * 3
        y      = floor(each.key / local.widgets_per_row) * 2
        width  = 3
        height = 2
      }
    }
  }

  dynamic "widget" {
    for_each = length(local.error_indexes) >0 ? local.error_indexes : tomap({})  
    content {
      widget_layout {
        x = (each.key % local.widgets_per_row) * 3 
        y = floor(each.key / local.widgets_per_row) * 2
        width = 3 
        height = 2 
      }
      group_definition {
        title       = "Estados de Erro"
        layout_type = "ordered"

        dynamic "widget" {
          for_each = local.error_indexes
          content {
            query_value_definition {
              title       = each.value.name
              title_size  = "16"
              title_align = "left"
              autoscale   = true
              precision   = 0
              request {
                query {
                  metric_query {
                    data_source = "metrics"
                    name        = each.value.code
                    query       = "sum:sentinel.state.${lower(each.value.code)}.count{*}"
                    aggregator  = "sum"
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
