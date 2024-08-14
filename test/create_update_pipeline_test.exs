defmodule CreateUpdatePipelineTest do
  use ExUnit.Case

  # Note: artifact_stores requires a Map and not a KeyWord since the
  # key is a user string and not predefined atom. This is the case for
  # all pieces of input data that use a user defined string as a key.
  @pipeline [
    artifact_store: [
      encryption_key: [id: "string", type: "string"],
      location: "string",
      type: "string"
    ],
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
      [
        name: "string",
        blockers: [[name: "string", type: "string"]],
        actions: [
          [
            action_type_id: [category: "string", owner: "string", provider: "string", version: "string"],
            name: "string",
            configuration: %{"string" => "string"},
            input_artifacts: [[name: "string"]],
            output_artificats: [[name: "string"]],
            region: "string",
            role_arn: "string",
            run_order: 12
          ]
        ]
      ]
    ],
    version: 1
  ]

  @expected %ExAws.Operation.JSON{
    stream_builder: nil,
    http_method: :post,
    parser: &Function.identity/1,
    error_parser: &Function.identity/1,
    path: "/",
    data: %{
      "pipeline" => %{
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
            "actions" => [
              %{
                "actionTypeId" => %{
                  "category" => "string",
                  "owner" => "string",
                  "provider" => "string",
                  "version" => "string"
                },
                "configuration" => %{"string" => "string"},
                "inputArtifacts" => [%{"name" => "string"}],
                "name" => "string",
                "outputArtificats" => [%{"name" => "string"}],
                "region" => "string",
                "roleArn" => "string",
                "runOrder" => 12
              }
            ],
            "blockers" => [%{"name" => "string", "type" => "string"}],
            "name" => "string"
          }
        ],
        "version" => 1
      }
    },
    params: %{},
    service: :codepipeline,
    before_request: nil
  }

  test "create pipeline" do
    expected =
      Map.put(@expected, :headers, [
        {"x-amz-target", "CodePipeline_20150709.CreatePipeline"},
        {"content-type", "application/x-amz-json-1.1"}
      ])

    assert expected == ExAws.CodePipeline.create_pipeline(@pipeline)
  end

  test "update pipeline" do
    expected =
      Map.put(@expected, :headers, [
        {"x-amz-target", "CodePipeline_20150709.UpdatePipeline"},
        {"content-type", "application/x-amz-json-1.1"}
      ])

    assert expected == ExAws.CodePipeline.update_pipeline(@pipeline)
  end
end
