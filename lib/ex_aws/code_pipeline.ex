defmodule ExAws.CodePipeline do
  @moduledoc """
    Operations on AWS CodePipeline
  """
  # version of the AWS API

  @version "20150709"
  @namespace "CodePipeline"
  import ExAws.Utils, only: [camelize_keys: 2]

  @type paging_options :: [
          {:next_token, binary}
        ]

  @type list_pipeline_executions_options :: [
          {:max_results, binary},
          {:next_token, binary},
          {:pipeline_name, binary}
        ]
  @type get_pipeline_options :: [
          {:version, binary}
        ]

  @key_spec %{
    max_results: "maxResults",
    next_token: "nextToken",
    pipeline_name: "pipelineName"
  }

  @doc """
    Returns information about a specified job and whether that job has
    been received by the job worker. Only used for custom actions.
  """
  def acknowledge_job(job_id, nonce) do
    %{"jobId" => job_id, "nonce" => nonce}
    |> request(:acknowledge_job)
  end

  @doc """
    Confirms a job worker has received the specified job. Only used for partner actions.
  """
  def acknowledge_third_party_job(client_token, job_id, nonce) do
    %{"clientToken" => client_token, "jobId" => job_id, "nonce" => nonce}
    |> request(:acknowledge_third_party_job)
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
    opts |> camelize_keys(spec: @key_spec) |> request(:list_pipelines)
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
    opts |> camelize_keys(spec: @key_spec) |> Map.merge(%{"pipelineName" => pipeline_name})
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
    opts |> camelize_keys(spec: @key_spec) |> Map.merge(%{"name" => name})
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
end
