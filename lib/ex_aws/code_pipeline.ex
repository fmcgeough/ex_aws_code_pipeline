defmodule ExAws.CodePipeline do
  @moduledoc """
    Operations on AWS CodePipeline
  """
  # version of the AWS API

  @version "20150709"
  @namespace "CodePipeline"

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
          version: binary
        ]

  @type approval_result :: %{status: binary, summary: binary}

  @type failure_details_options :: [
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

  @type artifact_details :: [
          minimum_count: integer,
          maximum_count: integer
        ]

  @type encryption_key :: [
          type: binary,
          id: binary
        ]

  @type artifact_store :: %{
          encryption_key: encryption_key,
          location: binary,
          type: binary
        }

  @type action_type_id :: %{
          category: binary,
          owner: binary,
          provider: binary,
          version: binary
        }

  @type input_artifact :: %{
          name: binary
        }

  @type block_declaration :: %{
          name: binary,
          type: binary
        }

  @type action_declaration :: %{
          action_type_id: action_type_id,
          configuration: map,
          input_artifacts: [input_artifact, ...],
          name: binary,
          output_artificats: [binary, ...],
          region: binary,
          role_arn: binary,
          run_order: integer,
          blockers: [block_declaration, ...]
        }

  @type stage_declaration :: [
          actions: [action_declaration, ...]
        ]
  @doc """
    Returns information about a specified job and whether that job has
    been received by the job worker. Only used for custom actions.

  ## Examples:

        iex> op = ExAws.CodePipeline.acknowledge_job("f4f4ff82-2d11-EXAMPLE", "3")
        iex> op.data
        %{"jobId" => "f4f4ff82-2d11-EXAMPLE", "nonce" => "3"}
        iex> op.headers
        [
        {"x-amz-target", "CodePipeline_20150709.AcknowledgeJob"},
        {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec acknowledge_job(job_id :: binary, nonce :: binary) :: ExAws.Operation.JSON.t()
  def acknowledge_job(job_id, nonce) do
    %{"jobId" => job_id, "nonce" => nonce}
    |> request(:acknowledge_job)
  end

  @doc """
    Confirms a job worker has received the specified job. Only used for partner actions.

  ## Examples:

        iex> op = ExAws.CodePipeline.acknowledge_third_party_job("ABCXYZ", "f4f4ff82-2d11-EXAMPLE", "3")
        iex> op.data
        %{
        "clientToken" => "ABCXYZ",
        "jobId" => "f4f4ff82-2d11-EXAMPLE",
        "nonce" => "3"
        }
        iex> op.headers
        [
        {"x-amz-target", "CodePipeline_20150709.AcknowledgeThirdPartyJob"},
        {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec acknowledge_third_party_job(client_token :: binary, job_id :: binary, nonce :: binary) ::
          ExAws.Operation.JSON.t()
  def acknowledge_third_party_job(client_token, job_id, nonce) do
    %{"clientToken" => client_token, "jobId" => job_id, "nonce" => nonce}
    |> request(:acknowledge_third_party_job)
  end

  @doc """
  """
  @type create_custom_action_type_opts :: [
          configuration_properties: [action_configuration_property, ...],
          settings: action_type_setting,
          input_artifact_details: artifact_details,
          output_artificat_details: artifact_details
        ]
  @spec create_custom_action_type(category :: binary, provider :: binary, version :: binary,
          opts: create_custom_action_type_opts
        ) :: ExAws.Operation.JSON.t()
  def create_custom_action_type(category, provider, version, opts \\ []) do
    opts
    |> camelize_keyword()
    |> Map.merge(%{"category" => category, "provider" => provider, "version" => version})
    |> request(:create_custom_action_type)
  end

  @doc """
    Creates a pipeline


  """
  @type create_pipeline_opts :: [
          artifact_store: artifact_store,
          artifact_stores: [binary: artifact_store],
          name: binary,
          role_arn: binary,
          stages: stage_declaration,
          version: integer
        ]
  @spec create_pipeline(pipeline :: create_pipeline_opts) :: ExAws.Operation.JSON.t()
  def create_pipeline(pipeline) do
    pipeline
    |> camelize_keyword()
    |> request(:create_pipeline)
  end

  @doc """
    Marks a custom action as deleted.

    poll_for_jobs for the custom action will fail after the action
    is marked for deletion. Only used for custom actions.
  """
  @spec delete_custom_action_type(category :: binary, provider :: binary, version :: binary) ::
          ExAws.Operation.JSON.t()
  def delete_custom_action_type(category, provider, version) do
    %{"category" => category, "provider" => provider, "version" => version}
    |> request(:delete_custom_action_type)
  end

  @doc """
    Deletes the specified pipeline.
  """
  @spec delete_pipeline(name :: binary) :: ExAws.Operation.JSON.t()
  def delete_pipeline(name) do
    %{"name" => name}
    |> request(:delete_pipeline)
  end

  @doc """
    deletes a web hook.
  """
  @spec delete_webhook(name :: binary) :: ExAws.Operation.JSON.t()
  def delete_webhook(name) do
    %{"name" => name}
    |> request(:delete_webhook)
  end

  @doc """
    Prevents artifacts in a pipeline from transitioning to the next stage in the pipeline.
  """
  @spec disable_stage_transition(
          pipeline_name :: binary,
          stage_name :: binary,
          transition_type :: binary,
          reason :: binary
        ) :: ExAws.Operation.JSON.t()
  def disable_stage_transition(pipeline_name, stage_name, transition_type, reason) do
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
  """
  @spec enable_stage_transition(
          pipeline_name :: binary,
          stage_name :: binary,
          transition_type :: binary
        ) :: ExAws.Operation.JSON.t()
  def enable_stage_transition(pipeline_name, stage_name, transition_type) do
    %{
      "pipelineName" => pipeline_name,
      "stageName" => stage_name,
      "transitionType" => transition_type
    }
    |> request(:disable_stage_transition)
  end

  @doc """
    Gets a summary of all of the pipelines associated with your account.
  """
  @spec list_pipelines() :: ExAws.Operation.JSON.t()
  @spec list_pipelines(opts :: paging_options) :: ExAws.Operation.JSON.t()
  def list_pipelines(opts \\ []) do
    opts |> camelize_keyword() |> request(:list_pipelines)
  end

  @doc """
    Gets a summary of the most recent executions for a pipeline.
  """
  @spec list_pipeline_executions(pipeline_name :: binary) :: ExAws.Operation.JSON.t()
  @spec list_pipeline_executions(
          pipeline_name :: binary,
          opts :: list_pipeline_executions_options
        ) :: ExAws.Operation.JSON.t()
  def list_pipeline_executions(pipeline_name, opts \\ []) do
    opts
    |> camelize_keyword()
    |> Map.merge(%{"pipelineName" => pipeline_name})
    |> request(:list_pipeline_executions)
  end

  @doc """
    Returns the metadata, structure, stages, and actions of a pipeline.

    Can be used to return the entire structure of a pipeline in JSON format,
    which can then be modified and used to update the pipeline structure
    with update_pipeline.

  """
  @spec get_pipeline(name :: binary) :: ExAws.Operation.JSON.t()
  @spec get_pipeline(name :: binary, opts :: get_pipeline_options) :: ExAws.Operation.JSON.t()
  def get_pipeline(name, opts \\ []) do
    opts
    |> camelize_keyword()
    |> Map.merge(%{"name" => name})
    |> request(:get_pipeline)
  end

  @doc """
    Returns information about an execution of a pipeline, including details
    about artifacts, the pipeline execution ID, and the name, version, and
    status of the pipeline.
  """
  @spec get_pipeline_execution(pipeline_name :: binary, pipeline_execution_id :: binary) ::
          ExAws.Operation.JSON.t()
  def get_pipeline_execution(pipeline_name, pipeline_execution_id) do
    %{"pipelineExecutionId" => pipeline_execution_id, "pipelineName" => pipeline_name}
    |> request(:get_pipeline_execution)
  end

  @doc """
    Returns information about the state of a pipeline, including the stages and actions.
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
  """
  def get_third_party_job_details(job_id, client_token) do
    %{"jobId" => job_id, "clientToken" => client_token}
    |> request(:get_third_party_job_details)
  end

  @doc """
    Provides the response to a manual approval request to AWS CodePipeline. Valid responses include Approved and Rejected.
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
    Represents the failure of a job as returned to the pipeline by a job worker. Only used for custom actions.
  """
  @spec put_job_failure_result(job_id :: binary, failure_details :: failure_details_options) ::
          ExAws.Operation.JSON.t()
  def put_job_failure_result(job_id, failure_details) do
    details = camelize_keyword(failure_details)

    %{"jobId" => job_id, "failureDetails" => details}
    |> request(:put_job_failure_result)
  end

  defp request(data, action, opts \\ %{}) do
    operation = action |> Atom.to_string() |> Macro.camelize()

    ExAws.Operation.JSON.new(
      :codepipeline,
      %{
        data: data,
        headers: [
          {"x-amz-target", "#{@namespace}_#{@version}.#{operation}"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
      }
      |> Map.merge(opts)
    )
  end

  # The API wants keywords in lower camel case format
  # this function works thru a KeyWord which may have one
  # layer of KeyWord within it and builds a map where keys
  # are in this format.
  #
  # [test: [my_key: "val"]] becomes %{"test" => %{"myKey" => "val"}}
  def camelize_keyword(a_list) when is_list(a_list) or is_map(a_list) do
    case Keyword.keyword?(a_list) or is_map(a_list) do
      true ->
        a_list
        |> Enum.reduce(%{}, fn {k, v}, acc ->
          k_str =
            case is_atom(k) do
              true ->
                k |> Atom.to_string() |> Macro.camelize() |> decap()

              false ->
                k
            end

          Map.put(acc, k_str, camelize_keyword(v))
        end)

      false ->
        a_list
        |> Enum.reduce([], fn item, acc -> [camelize_keyword(item) | acc] end)
        |> Enum.reverse()
    end
  end

  def camelize_keyword(val), do: val

  defp decap(str) do
    first = String.slice(str, 0..0) |> String.downcase()
    first <> String.slice(str, 1..-1)
  end
end
