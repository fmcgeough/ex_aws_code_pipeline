defmodule CreateUpdatePipelineTest do
  use ExUnit.Case

  # Note: artifact_stores requires a Map and not a KeyWord since the
  # key is a user string and not predefined atom. This is the case for
  # all pieces of input data that use a user defined string as a key.
  @pipeline [
    role_arn: "arn:aws:iam::111111111111:role/AWS-CodePipeline-Service",
    stages: [
      [
        name: "Source",
        actions: [
          [
            input_artifacts: [],
            name: "Source",
            action_type_id: [
              category: "Source",
              owner: "AWS",
              version: "1",
              provider: "S3"
            ],
            output_artifacts: [
              [
                name: "MyApp"
              ]
            ],
            configuration: %{
              "S3Bucket" => "awscodepipeline-demo-bucket",
              "S3ObjectKey" => "aws-codepipeline-s3-aws-codedeploy_linux.zip"
            },
            run_order: 1
          ]
        ]
      ],
      [
        name: "Beta",
        actions: [
          [
            input_artifacts: [
              [
                name: "MyApp"
              ]
            ],
            name: "CodePipelineDemoFleet",
            action_type_id: [
              category: "Deploy",
              owner: "AWS",
              version: "1",
              provider: "CodeDeploy"
            ],
            output_artifacts: [],
            configuration: [
              application_name: "CodePipelineDemoApplication",
              deployment_group_name: "CodePipelineDemoFleet"
            ],
            run_order: 1
          ]
        ]
      ]
    ],
    artifact_store: [
      type: "S3",
      location: "codepipeline-us-east-1-11EXAMPLE11"
    ],
    name: "MySecondPipeline",
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
          "location" => "codepipeline-us-east-1-11EXAMPLE11",
          "type" => "S3"
        },
        "name" => "MySecondPipeline",
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
                  "applicationName" => "CodePipelineDemoApplication",
                  "deploymentGroupName" => "CodePipelineDemoFleet"
                },
                "inputArtifacts" => [%{"name" => "MyApp"}],
                "name" => "CodePipelineDemoFleet",
                "outputArtifacts" => [],
                "runOrder" => 1
              }
            ],
            "name" => "Beta"
          }
        ],
        "version" => 1
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

  test "create pipeline" do
    expected =
      Map.put(@expected, :headers, [
        {"x-amz-target", "CodePipeline_20150709.CreatePipeline"},
        {"content-type", "application/x-amz-json-1.1"}
      ])

    assert expected == ExAws.CodePipeline.create_pipeline(@pipeline)
  end

  test "update pipeline" do
    # no tags in update_pipeline
    data_without_tags = Map.delete(@expected.data, "tags")

    expected =
      @expected
      |> Map.put(:data, data_without_tags)
      |> Map.put(:headers, [
        {"x-amz-target", "CodePipeline_20150709.UpdatePipeline"},
        {"content-type", "application/x-amz-json-1.1"}
      ])

    assert expected == ExAws.CodePipeline.update_pipeline(@pipeline)
  end
end
