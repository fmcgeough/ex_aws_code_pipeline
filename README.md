# AWS CodePipeline API

AWS Code Pipeline Service module for [ex_aws](https://github.com/ex-aws/ex_aws).

## Installation

The package can be installed by adding ex_aws_code_pipeline to your list of dependencies in mix.exs along with :ex_aws and your preferred JSON codec / http client. Example:

```elixir
def deps do
  [
    {:ex_aws, "~> 2.0"},
    {:ex_aws_code_pipeline, "~> 2.1"},
    {:poison, "~> 3.0"},
    {:hackney, "~> 1.9"},
  ]
end
```

## Documentation

* [ex_aws](https://hexdocs.pm/ex_aws)
* [AWS CodePipeline API](https://docs.aws.amazon.com/codepipeline/latest/APIReference/Welcome.html)
* [Go API for CodePipeline](https://github.com/aws/aws-sdk-go/blob/master/models/apis/codepipeline/2015-07-09/api-2.json)

## License

[License](LICENSE)
