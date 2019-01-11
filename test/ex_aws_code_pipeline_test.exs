defmodule ExAwsCodePipelineTest do
  use ExUnit.Case
  doctest ExAws.CodePipeline

  test "create pipeline" do
    pipeline = [
      artifact_store: %{
        encryption_key: [id: "string", type: "string"],
        location: "string",
        type: "string"
      },
      artifact_stores: %{
        "mykey" => [
          encryption_key: [id: "string", type: "string"],
          location: "string",
          type: "string"
        ]
      },
      name: "string",
      role_arn: "string",
      stages: [
        %{
          actions: [
            action_type_id: %{
              category: "string",
              owner: "string",
              provider: "string",
              version: "string"
            },
            configuration: %{"string" => "string"},
            input_artifacts: [name: "string"],
            name: "string",
            output_artificats: [name: "string"],
            region: "string",
            role_arn: "string",
            run_order: 12
          ],
          blockers: [
            %{name: "string", type: "string"}
          ],
          name: "string"
        }
      ],
      version: 1
    ]

    op = ExAws.CodePipeline.create_pipeline(pipeline)

    assert op.headers == [
             {"x-amz-target", "CodePipeline_20150709.CreatePipeline"},
             {"content-type", "application/x-amz-json-1.1"}
           ]

    assert op.data == %{
             "artifactStore" => %{
               "encryptionKey" => %{"id" => "string", "type" => "string"},
               "location" => "string",
               "type" => "string"
             },
             "artifactStores" => %{
               "mykey" => %{
                 "encryptionKey" => %{"id" => "string", "type" => "string"},
                 "location" => "string",
                 "type" => "string"
               }
             },
             "name" => "string",
             "roleArn" => "string",
             "stages" => [
               %{
                 "actions" => %{
                   "actionTypeId" => %{
                     "category" => "string",
                     "owner" => "string",
                     "provider" => "string",
                     "version" => "string"
                   },
                   "configuration" => %{"string" => "string"},
                   "inputArtifacts" => %{"name" => "string"},
                   "name" => "string",
                   "outputArtificats" => %{"name" => "string"},
                   "region" => "string",
                   "roleArn" => "string",
                   "runOrder" => 12
                 },
                 "blockers" => [%{"name" => "string", "type" => "string"}],
                 "name" => "string"
               }
             ],
             "version" => 1
           }
  end
end
