defmodule ExAws.CodePipeline do
  @moduledoc """
    Operations on AWS CodePipeline
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

  Valid Values
  ```
  ["Source", "Build", "Deploy", "Test", "Invoke", "Approval"]
  ```
  """
  @type category() :: binary()

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

  @type action_configuration_property :: [
          description: binary,
          key: boolean,
          name: binary,
          queryable: boolean,
          required: boolean,
          secret: boolean,
          type: binary
        ]

  @type action_type_setting :: [
          entity_url_template: binary,
          execution_url_template: binary,
          revision_url_template: binary,
          third_party_configuration_url: binary
        ]

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

  @type artifact_store :: [
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

  @type stage_declaration :: [
          actions: [action_declaration, ...]
        ]

  @type create_custom_action_type_opts ::
          [
            configuration_properties: [action_configuration_property()],
            settings: action_type_setting()
          ]
          | %{
              optional(:configuration_properties) => [action_configuration_property()],
              optional(:settings) => action_type_setting()
            }

  @type pipeline_declaration :: [
          artifact_store: artifact_store,
          artifact_stores: [binary: artifact_store],
          name: binary,
          role_arn: binary,
          stages: [stage_declaration, ...],
          version: integer
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
  """
  @spec create_custom_action_type(
          category(),
          provider(),
          version(),
          artifact_details(),
          artifact_details(),
          create_custom_action_type_opts()
        ) :: ExAws.Operation.JSON.t()
  def create_custom_action_type(
        category,
        provider,
        version,
        input_artifact_details,
        output_artifact_details,
        opts \\ []
      )
      when category in @valid_categories do
    opts
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
  """
  @spec create_pipeline(pipeline :: pipeline_declaration) :: ExAws.Operation.JSON.t()
  def create_pipeline(pipeline) do
    details = pipeline |> Utils.keyword_to_map() |> Utils.camelize_map()

    %{"pipeline" => details}
    |> request(:create_pipeline)
  end

  @doc """
    Marks a custom action as deleted.

    poll_for_jobs for the custom action will fail after the action
    is marked for deletion. Only used for custom actions.

  ## Examples:

        iex> op = ExAws.CodePipeline.delete_custom_action_type("Source", "AWS CodeDeploy", "1")
        iex> op.data
        %{"category" => "Source", "provider" => "AWS CodeDeploy", "version" => "1"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.DeleteCustomActionType"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec delete_custom_action_type(category :: binary, provider :: binary, version :: binary) ::
          ExAws.Operation.JSON.t()
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
  @spec delete_pipeline(name :: binary) :: ExAws.Operation.JSON.t()
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
  @spec delete_webhook(name :: binary) :: ExAws.Operation.JSON.t()
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
  @spec deregister_webhook_with_third_party(name :: binary) :: ExAws.Operation.JSON.t()
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
  @spec disable_stage_transition(
          pipeline_name :: binary,
          stage_name :: binary,
          transition_type :: binary,
          reason :: binary
        ) :: ExAws.Operation.JSON.t()
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
  @spec enable_stage_transition(
          pipeline_name :: binary,
          stage_name :: binary,
          transition_type :: binary
        ) :: ExAws.Operation.JSON.t()
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
  @spec get_job_details(job_id :: binary) :: ExAws.Operation.JSON.t()
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
  @spec get_pipeline(name :: binary) :: ExAws.Operation.JSON.t()
  @spec get_pipeline(name :: binary, opts :: get_pipeline_options) :: ExAws.Operation.JSON.t()
  def get_pipeline(name, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"name" => name})
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
  @type list_action_types_options :: [
          action_owner_filter: binary,
          next_token: binary
        ]
  @spec list_action_types() :: ExAws.Operation.JSON.t()
  @spec list_action_types(opts :: list_action_types_options) :: ExAws.Operation.JSON.t()
  def list_action_types(opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> request(:list_action_types)
  end

  @doc """
    Gets a summary of the most recent executions for a pipeline.

  ## Examples:

        iex> op = ExAws.CodePipeline.list_pipeline_executions("MyPipeline")
        iex> op.data
        %{"pipelineName" => "MyPipeline"}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.ListPipelineExecutions"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec list_pipeline_executions(pipeline_name :: binary) :: ExAws.Operation.JSON.t()
  @spec list_pipeline_executions(
          pipeline_name :: binary,
          opts :: list_pipeline_executions_options
        ) :: ExAws.Operation.JSON.t()
  def list_pipeline_executions(pipeline_name, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"pipelineName" => pipeline_name})
    |> request(:list_pipeline_executions)
  end

  @doc """
    Gets a summary of all of the pipelines associated with your account.

  ## Examples:

        iex> op = ExAws.CodePipeline.list_pipelines()
        iex> op.data
        %{}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.ListPipelines"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec list_pipelines() :: ExAws.Operation.JSON.t()
  @spec list_pipelines(opts :: paging_options) :: ExAws.Operation.JSON.t()
  def list_pipelines(opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> request(:list_pipelines)
  end

  @doc """
    Gets a listing of all the webhooks in this region for this account.
    The output lists all webhooks and includes the webhook URL and ARN,
    as well the configuration for each webhook.

  ## Examples:

        iex> op = ExAws.CodePipeline.list_webhooks()
        iex> op.data
        %{}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.ListWebhooks"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @type list_webhooks_options :: [
          max_results: binary,
          next_token: binary
        ]
  @spec list_webhooks() :: ExAws.Operation.JSON.t()
  @spec list_webhooks(opts :: list_webhooks_options) :: ExAws.Operation.JSON.t()
  def list_webhooks(opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> request(:list_webhooks)
  end

  @doc """
    Returns information about any jobs for AWS CodePipeline to act upon.
    poll_for_jobs is only valid for action types with "Custom" in the owner field.
    If the action type contains "AWS" or "ThirdParty" in the owner field, the
    poll_for_jobs action returns an error.

  ## Examples:

        iex> op = ExAws.CodePipeline.poll_for_jobs([category: "Build", owner: "AWS", provider: "AWS CodeDeploy", version: "1"])
        iex> op.data
        %{"actionTypeId" => %{"category" => "Build", "owner" => "AWS", "provider" => "AWS CodeDeploy", "version" => "1"}}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.PollForJobs"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @type poll_for_jobs_opts :: [
          max_batch_size: integer,
          query_param: map
        ]
  @spec poll_for_jobs(action_type_id :: action_type_id) :: ExAws.Operation.JSON.t()
  @spec poll_for_jobs(action_type_id :: action_type_id, opts :: poll_for_jobs_opts) ::
          ExAws.Operation.JSON.t()
  def poll_for_jobs(action_type_id, opts \\ []) do
    action_type_data =
      action_type_id
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"actionTypeId" => action_type_data})
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

        iex> op = ExAws.CodePipeline.poll_for_third_party_jobs([category: "Build", owner: "Custom", provider: "MyProvider", version: "1"])
        iex> op.data
        %{"actionTypeId" => %{"category" => "Build", "owner" => "Custom", "provider" => "MyProvider", "version" => "1"}}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.PollForThirdPartyJobs"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @type poll_for_third_party_jobs_opts :: [
          max_batch_size: integer
        ]
  @spec poll_for_third_party_jobs(action_type_id :: action_type_id) :: ExAws.Operation.JSON.t()
  @spec poll_for_third_party_jobs(
          action_type_id :: action_type_id,
          opts :: poll_for_third_party_jobs_opts
        ) :: ExAws.Operation.JSON.t()
  def poll_for_third_party_jobs(action_type_id, opts \\ []) do
    action_type_data =
      action_type_id
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"actionTypeId" => action_type_data})
    |> request(:poll_for_third_party_jobs)
  end

  @doc """
    Provides information to AWS CodePipeline about new revisions to a source
  """
  @type action_revision :: [
          created: integer,
          revision_change_id: binary,
          revision_id: binary
        ]
  @spec put_action_revision(
          pipeline_name :: binary,
          stage_name :: binary,
          action_name :: binary,
          action_revision :: action_revision
        ) :: ExAws.Operation.JSON.t()
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
  @spec put_approval_result(
          pipeline_name :: binary,
          stage_name :: binary,
          action_name :: binary,
          token :: binary,
          result :: approval_result
        ) :: ExAws.Operation.JSON.t()
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

        iex> op = ExAws.CodePipeline.put_job_failure_result("MyJob", [external_execution_id: "id", message: "", type: "JobFailed"] )
        iex> op.data
        %{"jobId" => "MyJob", "failureDetails" => %{"externalExecutionId" => "id", "message" => "", "type" => "JobFailed"}}
        iex> op.headers
        [
          {"x-amz-target", "CodePipeline_20150709.PutJobFailureResult"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec put_job_failure_result(job_id :: binary, failure_details :: failure_details) ::
          ExAws.Operation.JSON.t()
  def put_job_failure_result(job_id, failure_details) do
    details =
      failure_details
      |> Utils.keyword_to_map()
      |> Utils.camelize_map()

    %{"jobId" => job_id, "failureDetails" => details}
    |> request(:put_job_failure_result)
  end

  @doc """
    Represents the success of a job as returned to the pipeline by a job worker.
    Only used for custom actions.
  """
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
  @spec put_job_success_result(job_id :: binary, opts :: put_job_success_result_opts) ::
          ExAws.Operation.JSON.t()
  def put_job_success_result(job_id, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"jobId" => job_id})
    |> request(:put_job_success_result)
  end

  @doc """
    Represents the failure of a third party job as returned to the pipeline by a job worker.
    Only used for partner actions.
  """
  @spec put_third_party_job_failure_result(
          job_id :: binary,
          client_token :: binary,
          failure_details :: failure_details
        ) :: ExAws.Operation.JSON.t()
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
  @type put_third_party_job_success_result_opts :: [
          continuation_token: binary,
          current_revision: current_revision,
          execution_details: execution_details
        ]
  @spec put_third_party_job_success_result(job_id :: binary, client_token :: binary) ::
          ExAws.Operation.JSON.t()
  @spec put_third_party_job_success_result(
          job_id :: binary,
          client_token :: binary,
          opts :: put_third_party_job_success_result_opts
        ) :: ExAws.Operation.JSON.t()
  def put_third_party_job_success_result(job_id, client_token, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"jobId" => job_id, "clientToken" => client_token})
    |> request(:put_third_party_job_success_result)
  end

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
  @spec put_webhook(webhook :: webhook_definition) :: ExAws.Operation.JSON.t()
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
  @spec retry_stage_execution(
          pipeline_name :: binary,
          stage_name :: binary,
          pipeline_execution_id :: binary
        ) :: ExAws.Operation.JSON.t()
  @spec retry_stage_execution(
          pipeline_name :: binary,
          stage_name :: binary,
          pipeline_execution_id :: binary,
          retry_mode :: binary
        ) :: ExAws.Operation.JSON.t()
  def retry_stage_execution(
        pipeline_name,
        stage_name,
        pipeline_execution_id,
        retry_mode \\ "FAILED_ACTIONS"
      ) do
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
  @type start_pipeline_execution_opts :: [
          client_request_token: binary
        ]
  @spec start_pipeline_execution(name :: binary) :: ExAws.Operation.JSON.t()
  @spec start_pipeline_execution(name :: binary, opts :: start_pipeline_execution_opts) ::
          ExAws.Operation.JSON.t()
  def start_pipeline_execution(name, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"name" => name})
    |> request(:start_pipeline_execution)
  end

  @doc """
  Updates a specified pipeline with edits or changes to its structure.

  Use a JSON file with the pipeline structure in conjunction with update_pipeline
  to provide the full structure of the pipeline. Updating the pipeline increases
  the version number of the pipeline by 1.
  """
  @spec update_pipeline(pipeline :: pipeline_declaration) :: ExAws.Operation.JSON.t()
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
