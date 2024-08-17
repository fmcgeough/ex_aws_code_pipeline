defmodule ExAws.CodePipeline do
  @moduledoc """
  Operations on AWS CodePipeline

  The documentation and types provided lean heavily on the [AWS documentation for
  CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_Operations.html).
  The AWS documentation is the definitive source of information and should be consulted to
  understand how to use CodePipeline and its API functions.

  Generally the functions take required parameters separately from any optional arguments. The
  optional arguments are passed as a Map (with a defined type).

  The defined types for the Maps used to pass optional arguments use the standard Elixir snake-case
  for keys. The API itself uses camel-case Strings for keys. The library provides the conversion.
  Most of the API keys use a lower-case letter for the first word and upper-case for the subsequent
  words. If there are exceptions to this rule they are handled by the library so an Elixir
  developer can just use standard snake-case for all the keys.

  ## Description

  AWS CodePipeline is a continuous delivery service you can use to model, visualize, and automate
  the steps required to release your software. You can quickly model and configure the different
  stages of a software release process. CodePipeline automates the steps required to release your
  software changes continuously.

  ## Resources

  - [CodePipeline User Guide](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
  - [CodePipeline API Reference Guide](https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_Operations.html)
  - [CLI Reference for CodePipeline}](https://docs.aws.amazon.com/cli/latest/reference/codepipeline/index.html)
  """

  # version of the AWS API

  @version "20150709"
  @namespace "CodePipeline"
  @valid_categories ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"]

  alias ExAws.CodePipeline.Utils
  alias ExAws.Operation.JSON, as: ExAwsOperationJSON

  @typedoc """
  The unique system-generated ID of the job for which you want to confirm receipt.

  Pattern: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
  """
  @type job_id() :: binary()

  @typedoc """
  A system-generated random number that CodePipeline uses to ensure that the job is being worked on
  by only one job worker. Get this number from the response of the `poll_for_jobs/2` request that
  returned this job.

  - Length Constraints: Minimum length of 1. Maximum length of 50.
  """
  @type nonce() :: binary()

  @typedoc """
  The clientToken portion of the clientId and clientToken pair used to verify that the calling
  entity is allowed access to the job and its details.

  - Length Constraints: Minimum length of 1. Maximum length of 256.
  """
  @type client_token() :: binary()

  @typedoc """
  The category of the custom action, such as a build action or a test action.

  ### Valid Values
  ```
  ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"]
  ```
  """
  @type category() :: binary()

  @typedoc """
  A `t:tag/0` key

  - Length Constraints: Minimum length of 1. Maximum length of 128.
  """
  @type tag_key() :: binary()

  @typedoc """
  A `t:tag/0` value

  - Length Constraints: Minimum length of 1. Maximum length of 256.
  """
  @type tag_value() :: binary()

  @typedoc """
  A tag is a key-value pair that is used to manage the resource.
  """
  @type tag() :: [key: tag_key(), value: tag_value()] | %{required(:key) => tag_key(), required(:value) => tag_value()}

  @typedoc """
  The provider of the service used in the custom action, such as CodeDeploy

  - Length Constraints: Minimum length of 1. Maximum length of 35.
  - Pattern: [0-9A-Za-z_-]+
  """
  @type provider() :: binary()

  @typedoc """
  The version identifier of the custom action

  - Length Constraints: Minimum length of 1. Maximum length of 9.
  - Pattern: [0-9A-Za-z_-]+
  """
  @type version() :: binary()

  @typedoc """
    Used generically to define a paging next_token
  """
  @type paging_options :: [
          next_token: binary
        ]

  @type list_pipeline_executions_options :: [
          max_results: binary,
          next_token: binary,
          pipeline_name: binary
        ]
  @type get_pipeline_options :: [
          version: integer
        ]

  @type approval_result :: %{status: binary, summary: binary}

  @type failure_details :: [
          external_execution_id: binary,
          message: binary,
          type: binary
        ]

  @typedoc """
  Represents information about an action configuration property

  - description - The description of the action configuration property that is displayed to users.
    - Length Constraints: Minimum length of 1. Maximum length of 160.
  - key - Whether the configuration property is a key
  - name - The name of the action configuration property.
    - Length Constraints: Minimum length of 1. Maximum length of 50.
  - queryable - Indicates that the property is used with `poll_for_jobs/2`.
    - When creating a custom action, an action can have up to one queryable property. If it has one,
    that property must be both required and not secret.
    - If you create a pipeline with a custom action type, and that custom action contains a
      queryable property, the value for that configuration property is subject to other
      restrictions. The value must be less than or equal to twenty (20) characters. The value can
      contain only alphanumeric characters, underscores, and hyphens.
  - required - Whether the configuration property is a required value.
  - secret - Whether the configuration property is secret. Secrets are hidden from all calls except
    for `get_job_details/1`, `get_third_party_job_details/2`, `poll_for_jobs/2`, and `poll_for_third_party_jobs/2`.
  - type - The type of the configuration property.
    ### Valid Values
    ```
    ["String", "Number", "Boolean"]
    ```
  """
  @type action_configuration_property :: [
          description: binary(),
          key: boolean(),
          name: binary(),
          queryable: boolean(),
          required: boolean(),
          secret: boolean(),
          type: binary()
        ]

  @typedoc """
  URL used in `t:action_type_setting/0`

  - Length Constraints: Minimum length of 1. Maximum length of 2048.
  """
  @type url_template() :: binary()

  @typedoc """
  Information about the settings for an action type

  - entity_url_template - The URL returned to the CodePipeline console that provides a deep link to
    the resources of the external system, such as the configuration page for a CodeDeploy deployment
    group. This link is provided as part of the action display in the pipeline.
  - execution_url_template - The URL returned to the CodePipeline console that contains a link to
    the top-level landing page for the external system, such as the console page for CodeDeploy.
    This link is shown on the pipeline view page in the CodePipeline console and provides a link to
    the execution entity of the external action.
  - revision_url_template - The URL returned to the CodePipeline console that contains a link to the
    page where customers can update or change the configuration of the external action.
  - third_party_configuration_url - The URL of a sign-up page where users can sign up for an
    external service and perform initial configuration of the action provided by that service.
  """
  @type action_type_setting ::
          [
            entity_url_template: url_template(),
            execution_url_template: url_template(),
            revision_url_template: url_template(),
            third_party_configuration_url: url_template()
          ]
          | %{
              optional(:entity_url_template) => url_template(),
              optional(:execution_url_template) => url_template(),
              optional(:revision_url_template) => url_template(),
              optional(:third_party_configuration_url) => url_template()
            }

  @typedoc """
  Information about the details of an artifact

  - minimum_count - The minimum number of artifacts allowed for the action type.
    Valid Range: Minimum value of 0. Maximum value of 5.
  - maximum_count -The maximum number of artifacts allowed for the action type.
    Valid Range: Minimum value of 0. Maximum value of 5.
  """
  @type artifact_details() ::
          [minimum_count: non_neg_integer(), maximum_count: non_neg_integer()]
          | %{required(:minimum_count) => non_neg_integer(), required(:maximum_count) => non_neg_integer()}

  @type encryption_key :: [
          type: binary,
          id: binary
        ]

  @type artifact_store() :: [
          encryption_key: encryption_key,
          location: binary,
          type: binary
        ]

  @type action_type_id :: %{
          category: binary,
          owner: binary,
          provider: binary,
          version: binary
        }

  @type input_artifact :: %{
          name: binary
        }

  @type block_declaration :: [
          name: binary,
          type: binary
        ]

  @type action_declaration :: [
          action_type_id: action_type_id,
          configuration: map,
          input_artifacts: [input_artifact, ...],
          name: binary,
          output_artificats: [binary, ...],
          region: binary,
          role_arn: binary,
          run_order: integer,
          blockers: [block_declaration, ...]
        ]

  @type stage_declaration :: [actions: [action_declaration()]]

  @typedoc """
  Optional input to the `create_custom_action_type/5` function

  Parameter can be provided as keyword or map.

  - configuration_properties - The configuration properties for the custom action.
  - settings - URLs that provide users information about this custom action
  """
  @type create_custom_action_type_optional() ::
          [
            configuration_properties: [action_configuration_property()],
            settings: action_type_setting()
          ]
          | %{
              optional(:configuration_properties) => [action_configuration_property()],
              optional(:settings) => action_type_setting()
            }

  @typedoc """
  The Amazon Resource Name (ARN) for CodePipeline to use to either perform actions with
  no action_role_arn, or to use to assume roles for actions with an action_role_arn.

  - Length Constraints: Maximum length of 1024.
  - Pattern: arn:aws(-[\w]+)*:iam::[0-9]{12}:role/.*
  """
  @type role_arn() :: binary()

  @typedoc """
  The name of the pipeline

  - Length Constraints: Minimum length of 1. Maximum length of 100.
  - Pattern: [A-Za-z0-9.@\-_]+
  """
  @type pipeline_name() :: binary()

  @typedoc """
  Represents the structure of actions and stages to be performed in the pipeline.
  """
  @type pipeline_declaration ::
          %{
            required(:name) => pipeline_name(),
            required(:role_arn) => role_arn(),
            required(:stages) => [stage_declaration()],
            optional(:artifact_store) => artifact_store(),
            optional(:artifact_stores) => [artifact_store()],
            optional(:version) => integer
          }
          | [
              {:name, pipeline_name()},
              {:role_arn, role_arn()},
              {:stages, [stage_declaration()]},
              {:artifact_store, artifact_store()},
              {:artifact_stores, [artifact_store()]},
              {:version, integer()}
            ]

  @type poll_for_jobs_opts :: [
          max_batch_size: integer,
          query_param: map
        ]

  @type list_webhooks_options :: [
          max_results: binary,
          next_token: binary
        ]

  @type poll_for_third_party_jobs_opts() :: [
          max_batch_size: integer
        ]

  @type execution_details :: [
          external_execution_id: binary,
          percent_complete: integer,
          summary: binary
        ]
  @type current_revision :: [
          change_identifier: binary,
          created: integer,
          revision: binary,
          revision_summary: binary
        ]
  @type put_job_success_result_opts :: [
          execution_details: execution_details,
          current_revision: current_revision
        ]

  @type list_action_types_options :: [
          action_owner_filter: binary,
          next_token: binary
        ]

  @type action_revision :: [
          created: integer,
          revision_change_id: binary,
          revision_id: binary
        ]

  @type put_third_party_job_success_result_opts :: [
          continuation_token: binary,
          current_revision: current_revision,
          execution_details: execution_details
        ]

  @type start_pipeline_execution_opts :: [
          client_request_token: binary
        ]

  @type authentication_configuration :: [
          allowed_iP_range: binary,
          secret_token: binary
        ]

  @type webhook_filter_rule :: [
          json_path: binary,
          match_equals: binary
        ]

  @type webhook_definition :: [
          authentication: binary,
          authentication_configuration: authentication_configuration,
          filters: [webhook_filter_rule, ...],
          name: binary,
          target_action: binary,
          target_pipeline: binary
        ]

  @doc """
  Returns information about a specified job and whether that job has been received by the job
  worker. Only used for custom actions.

  ## Examples:

      iex> ExAws.CodePipeline.acknowledge_job("f4f4ff82-2d11-EXAMPLE", "3")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"jobId" => "f4f4ff82-2d11-EXAMPLE", "nonce" => "3"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.AcknowledgeJob"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec acknowledge_job(job_id(), nonce()) :: ExAws.Operation.JSON.t()
  def acknowledge_job(job_id, nonce) do
    %{job_id: job_id, nonce: nonce}
    |> Utils.camelize_map()
    |> request(:acknowledge_job)
  end

  @doc """
  Confirms a job worker has received the specified job. Only used for partner actions.

  ## Examples:

      iex> ExAws.CodePipeline.acknowledge_third_party_job("ABCXYZ", "f4f4ff82-2d11-EXAMPLE", "3")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "clientToken" => "ABCXYZ",
          "jobId" => "f4f4ff82-2d11-EXAMPLE",
          "nonce" => "3"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.AcknowledgeThirdPartyJob"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec acknowledge_third_party_job(client_token(), job_id(), nonce()) :: ExAws.Operation.JSON.t()
  def acknowledge_third_party_job(client_token, job_id, nonce) do
    %{client_token: client_token, job_id: job_id, nonce: nonce}
    |> Utils.camelize_map()
    |> request(:acknowledge_third_party_job)
  end

  @doc """
  Creates a new custom action that can be used in all pipelines associated
  with the AWS account. Only used for custom actions.

  ## Examples

      iex> version = 1
      iex> category = "Build"
      iex> provider = "MyJenkinsProviderName"
      iex> input_artifact_details = %{maximum_count: 1, minimum_count: 0}
      iex> output_artifact_details = %{maximum_count: 1, minimum_count: 0}
      iex> opts = %{
      ...>  settings: %{
      ...>entity_url_template: "https://192.0.2.4/job/{Config:ProjectName}/",
      ...>    execution_url_template: "https://192.0.2.4/job/{Config:ProjectName}/lastSuccessfulBuild/{ExternalExecutionId}/"
      ...> },
      ...> configuration_properties: [
      ...>   %{
      ...>      name: "MyJenkinsExampleBuildProject",
      ...>      type: "String",
      ...>      description: "The name of the build project must be provided when this action is added to the pipeline.",
      ...>      key: true,
      ...>      required: true,
      ...>      secret: false,
      ...>      queryable: false
      ...>    }
      ...>  ]
      ...> }
      iex> ExAws.CodePipeline.create_custom_action_type(category, provider, version, input_artifact_details, output_artifact_details, opts)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "category" => "Build",
          "configurationProperties" => [
            %{
              "description" => "The name of the build project must be provided when this action is added to the pipeline.",
              "key" => true,
              "name" => "MyJenkinsExampleBuildProject",
              "queryable" => false,
              "required" => true,
              "secret" => false,
              "type" => "String"
            }
          ],
          "inputArtifactDetails" => %{"maximumCount" => 1, "minimumCount" => 0},
          "outputArtifactDetails" => %{"maximumCount" => 1, "minimumCount" => 0},
          "provider" => "MyJenkinsProviderName",
          "settings" => %{
            "entityUrlTemplate" => "https://192.0.2.4/job/{Config:ProjectName}/",
            "executionUrlTemplate" => "https://192.0.2.4/job/{Config:ProjectName}/lastSuccessfulBuild/{ExternalExecutionId}/"
          },
          "version" => 1
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.CreateCustomActionType"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }

      iex> version = 1
      iex> category = "Build"
      iex> provider = "MyJenkinsProviderName"
      iex> input_artifact_details = %{maximum_count: 1, minimum_count: 0}
      iex> output_artifact_details = %{maximum_count: 1, minimum_count: 0}
      iex> opts = [
      ...>  settings: [
      ...>    entity_url_template: "https://192.0.2.4/job/{Config:ProjectName}/",
      ...>    execution_url_template: "https://192.0.2.4/job/{Config:ProjectName}/lastSuccessfulBuild/{ExternalExecutionId}/"
      ...>  ],
      ...>  configuration_properties: [
      ...>    [
      ...>      name: "MyJenkinsExampleBuildProject",
      ...>      type: "String",
      ...>      description: "The name of the build project must be provided when this action is added to the pipeline.",
      ...>      key: true,
      ...>      required: true,
      ...>      secret: false,
      ...>      queryable: false
      ...>    ]
      ...>  ]
      ...> ]
      iex> ExAws.CodePipeline.create_custom_action_type(category, provider, version, input_artifact_details, output_artifact_details, opts)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "category" => "Build",
          "configurationProperties" => [
            %{
              "description" => "The name of the build project must be provided when this action is added to the pipeline.",
              "key" => true,
              "name" => "MyJenkinsExampleBuildProject",
              "queryable" => false,
              "required" => true,
              "secret" => false,
              "type" => "String"
            }
          ],
          "inputArtifactDetails" => %{"maximumCount" => 1, "minimumCount" => 0},
          "outputArtifactDetails" => %{"maximumCount" => 1, "minimumCount" => 0},
          "provider" => "MyJenkinsProviderName",
          "settings" => %{
            "entityUrlTemplate" => "https://192.0.2.4/job/{Config:ProjectName}/",
            "executionUrlTemplate" => "https://192.0.2.4/job/{Config:ProjectName}/lastSuccessfulBuild/{ExternalExecutionId}/"
          },
          "version" => 1
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.CreateCustomActionType"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }

  """
  @spec create_custom_action_type(
          category(),
          provider(),
          version(),
          artifact_details(),
          artifact_details(),
          create_custom_action_type_optional()
        ) :: ExAws.Operation.JSON.t()
  def create_custom_action_type(
        category,
        provider,
        version,
        input_artifact_details,
        output_artifact_details,
        optional_data \\ %{}
      )
      when category in @valid_categories do
    optional_data
    |> Utils.keyword_to_map()
    |> Map.merge(%{
      category: category,
      provider: provider,
      version: version,
      input_artifact_details: Utils.keyword_to_map(input_artifact_details),
      output_artifact_details: Utils.keyword_to_map(output_artifact_details)
    })
    |> Utils.camelize_map()
    |> request(:create_custom_action_type)
  end

  @doc """
  Creates a pipeline

  The `pipeline` argument must include either `artifact_store` or `artifact_stores`. You cannot use
  both. If you create a cross-region action in your pipeline, you must use `artifact_stores`.

  ## Examples

      iex> pipeline = %{
      ...>  role_arn: "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
      ...>  stages: [
      ...>    %{
      ...>      name: "Source",
      ...>      actions: [
      ...>        %{
      ...>          name: "Source",
      ...>          action_type_id: %{
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            category: "Source",
      ...>            provider: "S3"
      ...>          },
      ...>          configuration: %{
      ...>            "S3Bucket" => "awscodepipeline-demo-bucket",
      ...>            "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
      ...>          },
      ...>          input_artifacts: [],
      ...>          run_order: 1,
      ...>          output_artifacts: [%{name: "MyApp"}]
      ...>        }
      ...>      ]
      ...>    },
      ...>    %{
      ...>      name: "MySecondPipeline",
      ...>      version: 1,
      ...>      artifact_store: %{
      ...>        type: "S3",
      ...>        location: "codepipeline-us-east-1-11EXAMPLE11"
      ...>      },
      ...>      actions: [
      ...>        %{
      ...>          name: "CodePipelineDemoFleet",
      ...>          action_type_id: %{
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            category: "Deploy",
      ...>            provider: "CodeDeploy"
      ...>          },
      ...>          configuration: %{
      ...>            "ApplicationName" => "CodePipelineDemoApplication",
      ...>            "DeploymentGroupName" => "CodePipelineDemoFleet"
      ...>          },
      ...>          input_artifacts: [%{name: "MyApp"}],
      ...>          run_order: 1,
      ...>          output_artifacts: []
      ...>        }
      ...>      ]
      ...>    }
      ...>  ]
      ...>}
      iex> ExAws.CodePipeline.create_pipeline(pipeline)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "pipeline" => %{
            "roleArn" => "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
            "stages" => [
              %{
                "actions" => [
                  %{
                    "actionTypeId" => %{
                      "category" => "Source",
                      "owner" => "AWS",
                      "provider" => "S3",
                      "version" => "1"
                    },
                    "configuration" => %{
                      "S3Bucket" => "awscodepipeline-demo-bucket",
                      "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
                    },
                    "inputArtifacts" => [],
                    "name" => "Source",
                    "outputArtifacts" => [%{"name" => "MyApp"}],
                    "runOrder" => 1
                  }
                ],
                "name" => "Source"
              },
              %{
                "actions" => [
                  %{
                    "actionTypeId" => %{
                      "category" => "Deploy",
                      "owner" => "AWS",
                      "provider" => "CodeDeploy",
                      "version" => "1"
                    },
                    "configuration" => %{
                      "ApplicationName" => "CodePipelineDemoApplication",
                      "DeploymentGroupName" => "CodePipelineDemoFleet"
                    },
                    "inputArtifacts" => [%{"name" => "MyApp"}],
                    "name" => "CodePipelineDemoFleet",
                    "outputArtifacts" => [],
                    "runOrder" => 1
                  }
                ],
                "artifactStore" => %{
                  "location" => "codepipeline-us-east-1-11EXAMPLE11",
                  "type" => "S3"
                },
                "name" => "MySecondPipeline",
                "version" => 1
              }
            ]
          },
          "tags" => []
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.CreatePipeline"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }

      iex> pipeline = [
      ...>  role_arn: "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
      ...>  stages: [
      ...>    [
      ...>      name: "Source",
      ...>      actions: [
      ...>        [
      ...>          input_artifacts: [],
      ...>          name: "Source",
      ...>          action_type_id: [
      ...>            category: "Source",
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            provider: "S3"
      ...>          ],
      ...>          output_artifacts: [
      ...>            [
      ...>              name: "MyApp"
      ...>            ]
      ...>          ],
      ...>          configuration: %{
      ...>            "S3Bucket" => "awscodepipeline-demo-bucket",
      ...>            "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
      ...>          },
      ...>          run_order: 1
      ...>        ]
      ...>      ]
      ...>    ],
      ...>    [
      ...>      name: "Beta",
      ...>      actions: [
      ...>        [
      ...>          input_artifacts: [[name: "MyApp"]],
      ...>          name: "CodePipelineDemoFleet",
      ...>          action_type_id: [
      ...>            category: "Deploy",
      ...>            owner: "AWS",
      ...>            version: "1",
      ...>            provider: "CodeDeploy"
      ...>          ],
      ...>          output_artifacts: [],
      ...>          configuration: %{
      ...>            "ApplicationName" => "CodePipelineDemoApplication",
      ...>            "DeploymentGroupName" => "CodePipelineDemoFleet"
      ...>          },
      ...>          run_order: 1
      ...>        ]
      ...>      ],
      ...>      artifact_store: [
      ...>        type: "S3",
      ...>        location: "codepipeline-us-east-1-11EXAMPLE11"
      ...>      ],
      ...>      name: "MySecondPipeline",
      ...>      version: 1
      ...>    ]
      ...>  ]
      ...>]
      iex> ExAws.CodePipeline.create_pipeline(pipeline)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "pipeline" => %{
            "roleArn" => "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
            "stages" => [
              %{
                "actions" => [
                  %{
                    "actionTypeId" => %{
                      "category" => "Source",
                      "owner" => "AWS",
                      "provider" => "S3",
                      "version" => "1"
                    },
                    "configuration" => %{
                      "S3Bucket" => "awscodepipeline-demo-bucket",
                      "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
                    },
                    "inputArtifacts" => [],
                    "name" => "Source",
                    "outputArtifacts" => [%{"name" => "MyApp"}],
                    "runOrder" => 1
                  }
                ],
                "name" => "Source"
              },
              %{
                "actions" => [
                  %{
                    "actionTypeId" => %{
                      "category" => "Deploy",
                      "owner" => "AWS",
                      "provider" => "CodeDeploy",
                      "version" => "1"
                    },
                    "configuration" => %{
                      "ApplicationName" => "CodePipelineDemoApplication",
                      "DeploymentGroupName" => "CodePipelineDemoFleet"
                    },
                    "inputArtifacts" => [%{"name" => "MyApp"}],
                    "name" => "CodePipelineDemoFleet",
                    "outputArtifacts" => [],
                    "runOrder" => 1
                  }
                ],
                "artifactStore" => %{
                  "location" => "codepipeline-us-east-1-11EXAMPLE11",
                  "type" => "S3"
                },
                "name" => "MySecondPipeline",
                "version" => 1
              }
            ]
          },
          "tags" => []
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.CreatePipeline"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec create_pipeline(pipeline_declaration(), [tag()]) :: ExAws.Operation.JSON.t()
  def create_pipeline(pipeline, tags \\ []) do
    tags =
      case Enum.empty?(tags) do
        false -> Enum.map(tags, &Utils.keyword_to_map/1)
        true -> []
      end

    %{pipeline: Utils.keyword_to_map(pipeline), tags: tags}
    |> Utils.camelize_map()
    |> request(:create_pipeline)
  end

  @doc """
    Marks a custom action as deleted.

    `PollForJobs` for the custom action will fail after the action
    is marked for deletion. Only used for custom actions.

  ## Examples:

      iex> ExAws.CodePipeline.delete_custom_action_type("Source", "AWS CodeDeploy", "1")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "category" => "Source",
          "provider" => "AWS CodeDeploy",
          "version" => "1"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.DeleteCustomActionType"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec delete_custom_action_type(category(), provider(), version()) :: ExAws.Operation.JSON.t()
  def delete_custom_action_type(category, provider, version)
      when category in ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"] do
    %{"category" => category, "provider" => provider, "version" => version}
    |> request(:delete_custom_action_type)
  end

  @doc """
    Deletes the specified pipeline.

  ## Examples:

        iex> op = ExAws.CodePipeline.delete_pipeline("MyPipeline")
        iex> op.data
        %{"name" => "MyPipeline"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.DeletePipeline"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec delete_pipeline(binary()) :: ExAws.Operation.JSON.t()
  def delete_pipeline(name) do
    %{"name" => name}
    |> request(:delete_pipeline)
  end

  @doc """
    Deletes a web hook.

  ## Examples:

        iex> op = ExAws.CodePipeline.delete_webhook("MyWebhook")
        iex> op.data
        %{"name" => "MyWebhook"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.DeleteWebhook"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec delete_webhook(binary()) :: ExAws.Operation.JSON.t()
  def delete_webhook(name) do
    %{"name" => name}
    |> request(:delete_webhook)
  end

  @doc """
    Removes the connection between the webhook that was created by CodePipeline
    and the external tool with events to be detected. Currently only supported
    for webhooks that target an action type of GitHub.

  ## Examples:

        iex> op = ExAws.CodePipeline.deregister_webhook_with_third_party("MyWebhook")
        iex> op.data
        %{"webhookName" => "MyWebhook"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.DeregisterWebhookWithThirdParty"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec deregister_webhook_with_third_party(binary()) :: ExAws.Operation.JSON.t()
  def deregister_webhook_with_third_party(name) do
    %{"webhookName" => name}
    |> request(:deregister_webhook_with_third_party)
  end

  @doc """
    Prevents artifacts in a pipeline from transitioning to the next stage in the pipeline.

  ## Examples:

        iex> op = ExAws.CodePipeline.disable_stage_transition("pipeline", "stage", "Inbound", "Removing")
        iex> op.data
        %{
          "pipelineName" => "pipeline",
          "stageName" => "stage",
          "transitionType" => "Inbound",
          "reason" => "Removing"
        }
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.DisableStageTransition"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec disable_stage_transition(binary(), binary(), binary(), binary()) :: ExAws.Operation.JSON.t()
  def disable_stage_transition(pipeline_name, stage_name, transition_type, reason)
      when transition_type in ["Inbound", "Outbound"] do
    %{
      "pipelineName" => pipeline_name,
      "stageName" => stage_name,
      "transitionType" => transition_type,
      "reason" => reason
    }
    |> request(:disable_stage_transition)
  end

  @doc """
    Enables artifacts in a pipeline to transition to a stage in a pipeline.

  ## Examples:

        iex> op = ExAws.CodePipeline.enable_stage_transition("pipeline", "stage", "Inbound")
        iex> op.data
        %{
          "pipelineName" => "pipeline",
          "stageName" => "stage",
          "transitionType" => "Inbound"
        }
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.EnableStageTransition"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec enable_stage_transition(binary(), binary(), binary()) :: ExAws.Operation.JSON.t()
  def enable_stage_transition(pipeline_name, stage_name, transition_type)
      when transition_type in ["Inbound", "Outbound"] do
    %{
      "pipelineName" => pipeline_name,
      "stageName" => stage_name,
      "transitionType" => transition_type
    }
    |> request(:enable_stage_transition)
  end

  @doc """
    Returns information about a job. Only used for custom actions.

    ## Important

    When this API is called, AWS CodePipeline returns temporary credentials for
    the Amazon S3 bucket used to store artifacts for the pipeline, if the action
    requires access to that Amazon S3 bucket for input or output artifacts.
    Additionally, this API returns any secret values defined for the action.

  ## Examples:

        iex> op = ExAws.CodePipeline.get_job_details("MyJob")
        iex> op.data
        %{"jobId" => "MyJob"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.GetJobDetails"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec get_job_details(binary()) :: ExAws.Operation.JSON.t()
  def get_job_details(job_id) do
    %{"jobId" => job_id}
    |> request(:get_job_details)
  end

  @doc """
    Returns the metadata, structure, stages, and actions of a pipeline.

    Can be used to return the entire structure of a pipeline in JSON format,
    which can then be modified and used to update the pipeline structure
    with update_pipeline.

  ## Examples:

        iex> op = ExAws.CodePipeline.get_pipeline("MyPipeline", [version: 1])
        iex> op.data
        %{"name" => "MyPipeline", "version" => 1}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.GetPipeline"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec get_pipeline(binary(), get_pipeline_options()) :: ExAws.Operation.JSON.t()
  def get_pipeline(name, opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Map.merge(%{name: name})
    |> Utils.camelize_map()
    |> request(:get_pipeline)
  end

  @doc """
    Returns information about an execution of a pipeline, including details
    about artifacts, the pipeline execution ID, and the name, version, and
    status of the pipeline.

  ## Examples:

        iex> op = ExAws.CodePipeline.get_pipeline_execution("MyPipeline", "executionId")
        iex> op.data
        %{"pipelineName" => "MyPipeline", "pipelineExecutionId" => "executionId"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.GetPipelineExecution"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec get_pipeline_execution(pipeline_name :: binary, pipeline_execution_id :: binary) ::
          ExAws.Operation.JSON.t()
  def get_pipeline_execution(pipeline_name, pipeline_execution_id) do
    %{"pipelineExecutionId" => pipeline_execution_id, "pipelineName" => pipeline_name}
    |> request(:get_pipeline_execution)
  end

  @doc """
    Returns information about the state of a pipeline, including the stages and actions.

  ## Examples:

        iex> op = ExAws.CodePipeline.get_pipeline_state("MyPipeline")
        iex> op.data
        %{"name" => "MyPipeline"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.GetPipelineState"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec get_pipeline_state(name :: binary) :: ExAws.Operation.JSON.t()
  def get_pipeline_state(name) do
    %{"name" => name}
    |> request(:get_pipeline_state)
  end

  @doc """
    Requests the details of a job for a third party action. Only used for partner actions.

    IMPORTANT: When this API is called, AWS CodePipeline returns temporary credentials
    for the Amazon S3 bucket used to store artifacts for the pipeline, if the action
    requires access to that Amazon S3 bucket for input or output artifacts. Additionally,
    this API returns any secret values defined for the action.

  ## Examples:

        iex> op = ExAws.CodePipeline.get_third_party_job_details("MyJob", "ClientToken")
        iex> op.data
        %{"clientToken" => "ClientToken", "jobId" => "MyJob"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.GetThirdPartyJobDetails"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec get_third_party_job_details(job_id :: binary, client_token :: binary) ::
          ExAws.Operation.JSON.t()
  def get_third_party_job_details(job_id, client_token) do
    %{"jobId" => job_id, "clientToken" => client_token}
    |> request(:get_third_party_job_details)
  end

  @doc """
    Gets a summary of all AWS CodePipeline action types associated with your account.

  ## Examples:

        iex> op = ExAws.CodePipeline.list_action_types([action_owner_filter: "MyFilter", next_token: "ClientToken"])
        iex> op.data
        %{"actionOwnerFilter" => "MyFilter", "nextToken" => "ClientToken"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.ListActionTypes"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec list_action_types(list_action_types_options()) :: ExAws.Operation.JSON.t()
  def list_action_types(opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Utils.camelize_map()
    |> request(:list_action_types)
  end

  @doc """
    Gets a summary of the most recent executions for a pipeline.

  ## Examples:

      iex> ExAws.CodePipeline.list_pipeline_executions("MyPipeline")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"pipelineName" => "MyPipeline"},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.ListPipelineExecutions"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec list_pipeline_executions(binary(), list_pipeline_executions_options()) :: ExAws.Operation.JSON.t()
  def list_pipeline_executions(pipeline_name, opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Map.merge(%{pipeline_name: pipeline_name})
    |> Utils.camelize_map()
    |> request(:list_pipeline_executions)
  end

  @doc """
    Gets a summary of all of the pipelines associated with your account.

  ## Examples:

      iex> ExAws.CodePipeline.list_pipelines()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.ListPipelines"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec list_pipelines(paging_options()) :: ExAws.Operation.JSON.t()
  def list_pipelines(opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Utils.camelize_map()
    |> request(:list_pipelines)
  end

  @doc """
    Gets a listing of all the webhooks in this region for this account.
    The output lists all webhooks and includes the webhook URL and ARN,
    as well the configuration for each webhook.

  ## Examples:

      iex> ExAws.CodePipeline.list_webhooks()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.ListWebhooks"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec list_webhooks(list_webhooks_options()) :: ExAws.Operation.JSON.t()
  def list_webhooks(opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Utils.camelize_map()
    |> request(:list_webhooks)
  end

  @doc """
    Returns information about any jobs for AWS CodePipeline to act upon.
    poll_for_jobs is only valid for action types with "Custom" in the owner field.
    If the action type contains "AWS" or "ThirdParty" in the owner field, the
    poll_for_jobs action returns an error.

  ## Examples:

      iex> ExAws.CodePipeline.poll_for_jobs([category: "Build", owner: "AWS", provider: "AWS CodeDeploy", version: "1"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "actionTypeId" => %{
            "category" => "Build",
            "owner" => "AWS",
            "provider" => "AWS CodeDeploy",
            "version" => "1"
          }
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.PollForJobs"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec poll_for_jobs(action_type_id(), poll_for_jobs_opts()) :: ExAws.Operation.JSON.t()
  def poll_for_jobs(action_type_id, opts \\ []) do
    action_type_data = %{action_type_id: Utils.keyword_to_map(action_type_id)}

    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Map.merge(action_type_data)
    |> Utils.camelize_map()
    |> request(:poll_for_jobs)
  end

  @doc """
    Determines whether there are any third party jobs for a job worker to act on.
    Only used for partner actions.

  ## Important

    When this API is called, AWS CodePipeline returns temporary credentials for
    the Amazon S3 bucket used to store artifacts for the pipeline, if the action
    requires access to that Amazon S3 bucket for input or output artifacts.

  ## Examples:

      iex> ExAws.CodePipeline.poll_for_third_party_jobs([category: "Build", owner: "Custom", provider: "MyProvider", version: "1"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "actionTypeId" => %{
            "category" => "Build",
            "owner" => "Custom",
            "provider" => "MyProvider",
            "version" => "1"
          }
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.PollForThirdPartyJobs"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec poll_for_third_party_jobs(action_type_id(), poll_for_third_party_jobs_opts()) :: ExAws.Operation.JSON.t()
  def poll_for_third_party_jobs(action_type_id, opts \\ []) do
    action_type_data =
      action_type_id
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Map.merge(%{action_type_id: action_type_data})
    |> Utils.camelize_map()
    |> request(:poll_for_third_party_jobs)
  end

  @doc """
    Provides information to AWS CodePipeline about new revisions to a source
  """
  @spec put_action_revision(binary(), binary(), binary(), action_revision()) :: ExAws.Operation.JSON.t()
  def put_action_revision(pipeline_name, stage_name, action_name, action_revision) do
    revision_details =
      action_revision
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    %{
      "actionName" => action_name,
      "pipelineName" => pipeline_name,
      "actionRevision" => revision_details,
      "stageName" => stage_name
    }
    |> request(:put_action_revision)
  end

  @doc """
  Provides the response to a manual approval request to AWS CodePipeline.
  Valid responses include Approved and Rejected.
  """
  @spec put_approval_result(binary(), binary(), binary(), binary(), approval_result()) :: ExAws.Operation.JSON.t()
  def put_approval_result(pipeline_name, stage_name, action_name, token, result) do
    %{
      "pipelineName" => pipeline_name,
      "actionName" => action_name,
      "stageName" => stage_name,
      "token" => token,
      "result" => %{"status" => result.status, "summary" => result.summary}
    }
    |> request(:put_approval_result)
  end

  @doc """
    Represents the failure of a job as returned to the pipeline by a job worker.
    Only used for custom actions.

  ## Examples:

      iex> ExAws.CodePipeline.put_job_failure_result("MyJob", [external_execution_id: "id", message: "", type: "JobFailed"] )
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "externalExecutionId" => "id",
          "jobId" => "MyJob",
          "message" => "",
          "type" => "JobFailed"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodePipeline_20150709.PutJobFailureResult"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codepipeline,
        before_request: nil
      }
  """
  @spec put_job_failure_result(binary(), failure_details()) :: ExAws.Operation.JSON.t()
  def put_job_failure_result(job_id, failure_details) do
    failure_details
    |> Utils.keyword_to_map()
    |> Map.merge(%{job_id: job_id})
    |> Utils.camelize_map()
    |> request(:put_job_failure_result)
  end

  @doc """
    Represents the success of a job as returned to the pipeline by a job worker.
    Only used for custom actions.
  """
  @spec put_job_success_result(binary(), put_job_success_result_opts()) :: ExAws.Operation.JSON.t()
  def put_job_success_result(job_id, opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Map.merge(%{job_id: job_id})
    |> Utils.camelize_map()
    |> request(:put_job_success_result)
  end

  @doc """
    Represents the failure of a third party job as returned to the pipeline by a job worker.
    Only used for partner actions.
  """
  @spec put_third_party_job_failure_result(binary(), binary(), failure_details()) :: ExAws.Operation.JSON.t()
  def put_third_party_job_failure_result(job_id, client_token, failure_details) do
    details =
      failure_details
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    %{"jobId" => job_id, "clientToken" => client_token, "failureDetails" => details}
    |> request(:put_third_party_job_failure_result)
  end

  @doc """
    Represents the success of a third party job as returned to the pipeline by a job worker.
    Only used for partner actions.
  """
  @spec put_third_party_job_success_result(binary(), binary(), put_third_party_job_success_result_opts()) ::
          ExAws.Operation.JSON.t()
  def put_third_party_job_success_result(job_id, client_token, opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Map.merge(%{job_id: job_id, client_token: client_token})
    |> Utils.camelize_map()
    |> request(:put_third_party_job_success_result)
  end

  @doc """
    Defines a webhook and returns a unique webhook URL generated by
    CodePipeline.

    This URL can be supplied to third party source hosting
    providers to call every time there's a code change. When CodePipeline
    receives a POST request on this URL, the pipeline defined in the webhook is
    started as long as the POST request satisfied the authentication and filtering
    requirements supplied when defining the webhook. register_webhook_with_third_party
    and deregister_webhook_with_third_party APIs can be used to automatically configure
    supported third parties to call the generated webhook URL.

  ## Examples:

        iex> op = ExAws.CodePipeline.put_webhook("MyWebHook")
        iex> op.data
        %{"webhook" => "MyWebHook"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.PutWebhook"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec put_webhook(webhook_definition()) :: ExAws.Operation.JSON.t()
  def put_webhook(webhook) do
    details =
      webhook
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    %{"webhook" => details}
    |> request(:put_webhook)
  end

  @doc """
    Configures a connection between the webhook that was created and
    the external tool with events to be detected.

  ## Examples:

        iex> op = ExAws.CodePipeline.register_webhook_with_third_party("MyWebHook")
        iex> op.data
        %{"webhookName" => "MyWebHook"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.RegisterWebhookWithThirdParty"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec register_webhook_with_third_party(webhook_name :: binary) :: ExAws.Operation.JSON.t()
  def register_webhook_with_third_party(webhook_name) do
    %{"webhookName" => webhook_name}
    |> request(:register_webhook_with_third_party)
  end

  @doc """
    Resumes the pipeline execution by retrying the last failed
    actions in a stage

  ## Examples:

        iex> op = ExAws.CodePipeline.retry_stage_execution("MyPipeline", "MyStage", "ExecutionId")
        iex> op.data
        %{
          "pipelineExecutionId" => "ExecutionId",
          "pipelineName" => "MyPipeline",
          "retryMode" => "FAILED_ACTIONS",
          "stageName" => "MyStage"
        }
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.RetryStageExecution"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec retry_stage_execution(binary(), binary(), binary(), binary()) :: ExAws.Operation.JSON.t()
  def retry_stage_execution(pipeline_name, stage_name, pipeline_execution_id, retry_mode \\ "FAILED_ACTIONS") do
    %{
      "pipelineExecutionId" => pipeline_execution_id,
      "pipelineName" => pipeline_name,
      "retryMode" => retry_mode,
      "stageName" => stage_name
    }
    |> request(:retry_stage_execution)
  end

  @doc """
    Starts the specified pipeline.

    Specifically, it begins processing the latest commit to the
    source location specified as part of the pipeline.


  ## Examples:

        iex> op = ExAws.CodePipeline.start_pipeline_execution("MyPipeline", [client_request_token: "Test"])
        iex> op.data
        %{
          "clientRequestToken" => "Test",
          "name" => "MyPipeline"
        }
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.StartPipelineExecution"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec start_pipeline_execution(binary(), start_pipeline_execution_opts()) :: ExAws.Operation.JSON.t()
  def start_pipeline_execution(name, opts \\ []) do
    case Enum.empty?(opts) do
      true -> %{}
      false -> Utils.keyword_to_map(opts)
    end
    |> Map.merge(%{name: name})
    |> Utils.camelize_map()
    |> request(:start_pipeline_execution)
  end

  @doc """
  Updates a specified pipeline with edits or changes to its structure.

  Use a JSON file with the pipeline structure in conjunction with update_pipeline
  to provide the full structure of the pipeline. Updating the pipeline increases
  the version number of the pipeline by 1.
  """
  @spec update_pipeline(pipeline_declaration()) :: ExAws.Operation.JSON.t()
  def update_pipeline(pipeline) do
    details =
      pipeline
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    %{"pipeline" => details}
    |> request(:update_pipeline)
  end

  @doc """
    Provided as a by-pass for developers that want to pass in their
    own JSON instead of relying on the individual functions to format
    the JSON data.

    The action has to be an atom that aligns with one of the CodePipeline
    API calls (see calls above for examples).
  """
  def direct_request(action, data) do
    request(data, action)
  end

  defp request(data, action) do
    operation = action |> Atom.to_string() |> Macro.camelize()

    ExAwsOperationJSON.new(
      :codepipeline,
      %{
        data: data,
        headers: [
          {"x-amz-target", "#{@namespace}_#{@version}.#{operation}"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
      }
    )
  end
end
