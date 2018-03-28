defmodule ExAws.CodePipeline do
  @moduledoc """
    Operations on AWS CodePipeline
  """
  # version of the AWS API

  @version "20150709"
  @namespace "CodePipeline"
  import ExAws.Utils, only: [camelize_keys: 1, camelize_keys: 2]

  @type paging_options :: [
          {:next_token, binary}
        ]

  @type list_pipeline_executions_options :: [
          {:max_results, binary},
          {:next_token, binary},
          {:pipeline_name, binary}
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

  @spec list_pipelines() :: ExAws.Operation.JSON.t()
  @spec list_pipelines(opts :: paging_options) :: ExAws.Operation.JSON.t()
  def list_pipelines(opts \\ []) do
    opts |> camelize_keys() |> request(:list_pipelines)
  end

  @spec list_pipeline_executions() :: ExAws.Operation.JSON.t()
  @spec list_pipeline_executions(opts :: list_pipeline_executions_options) ::
          ExAws.Operation.JSON.t()
  def list_pipeline_executions(opts \\ []) do
    opts |> camelize_keys(@key_spec) |> request(:list_pipeline_executions)
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
