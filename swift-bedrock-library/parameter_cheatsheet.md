

## Text Generation parameters

### Nova 
[user guide](https://docs.aws.amazon.com/nova/latest/userguide/complete-request-schema.html)

| parameter   | minValue | maxValue  | defaultValue | optional or required |
| ----------- | -------- | --------- | ------------ | -------------------- |
| temperature | 0.00001  | 1         | 0.7          | optional             |
| maxTokens   | 1        | 5_000     | "dynamic"?   | optional             |
| topP        | 0        | 1.0       | 0.9          | optional             |
| topK        | 0        | Not found | 50           | optional             |


| parameter | maxLength |
| --------- | --------- |
| prompt    | Not found |


| parameter     | maxSequences | defaultVal |
| ------------- | ------------ | ---------- |
| stopSequences | Not found    | `[]`       |

### Titan 
[user guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-text.html)

| parameter   | minValue      | maxValue         | defaultValue  | optional or required |
| ----------- | ------------- | ---------------- | ------------- | -------------------- |
| temperature | 0.0           | 1.0              | 0.7           | required             |
| maxTokens   | 0             | depends on model | 512           | required             |
| topP        | 0             | 1                | 0.9           | required             |
| topK        | Not supported | Not supported    | Not supported | required             |

| model              | max return tokens |
| ------------------ | ----------------- |
| Titan Text Lite    | 4_096             |
| Titan Text Express | 8_192             |
| Titan Text Premier | 3_072             |


| parameter | maxLength |
| --------- | --------- |
| prompt    | ???       |


| parameter     | maxSequences | defaultVal |
| ------------- | ------------ | ---------- |
| stopSequences | ???          | `[]`       |

### Claude

[user guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-anthropic-claude-messages.html)

| parameter   | minValue | maxValue             | defaultValue          | optional or required |
| ----------- | -------- | -------------------- | --------------------- | -------------------- |
| temperature | 0        | 1                    | 1                     | optional             |
| maxTokens   | 1        | depends on the model | Not found             | required             |
| topP        | 0        | 1                    | 0.999                 | optional             |
| topK        | 0        | 500                  | "disabled by default" | optional             |

[model comparison](https://docs.anthropic.com/en/docs/about-claude/models/all-models#model-comparison)

| models                            | max return tokens |
| --------------------------------- | ----------------- |
| 3 Opus                            | 4_096             |
| 3 Haiku                           | 4_096             |
| 3.5 Haiku                         | 8_192             |
| 3.5 Sonnet                        | 8_192             |
| 3.7 Sonnet                        | 8_192             |
| 3.7 Sonnet with extended thinking | 64_000            |

| parameter | maxLength |
| --------- | --------- |
| prompt    | 200_000   |


| parameter     | maxSequences | defaultVal |
| ------------- | ------------ | ---------- |
| stopSequences | 8191         | `[]`       |

### DeepSeek
 
[user guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-deepseek.html)
[deepseek docs](https://api-docs.deepseek.com/quick_start/parameter_settings)

| parameter   | minValue      | maxValue      | defaultValue  | optional or required |
| ----------- | ------------- | ------------- | ------------- | -------------------- |
| temperature | 0             | 1             | 1             | required             |
| maxTokens   | 1             | 32_768        | Not found     | required             |
| topP        | 0             | 1             | Not found     | required             |
| topK        | Not supported | Not supported | Not supported | required             |


| parameter | maxLength |
| --------- | --------- |
| prompt    | Not found |


| parameter     | maxSequences | defaultVal |
| ------------- | ------------ | ---------- |
| stopSequences | 10           | `[]`       |

### Llama
 
[user guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-text.html)

- Llama 3 Instruct
- Llama 3.1 Instruct
- Llama 3.2 Instruct
- Llama 3.3 Instruct

| parameter   | minValue      | maxValue      | defaultValue  | optional or required |
| ----------- | ------------- | ------------- | ------------- | -------------------- |
| temperature | 0             | 1             | 0.5           | optional             |
| maxTokens   | 1             | 2_048         | 512           | optional             |
| topP        | 0             | 1             | 0.9           | optional             |
| topK        | Not supported | Not supported | Not supported | optional             |


| parameter | maxLength |
| --------- | --------- |
| prompt    | Not found |


| parameter     | maxSequences  | defaultVal    |
| ------------- | ------------- | ------------- |
| stopSequences | Not supported | Not supported |


## Image Generation parameters

### Nova 
[user guide](https://docs.aws.amazon.com/nova/latest/userguide/image-gen-req-resp-structure.html)

#### General 

| parameter  | minValue | maxValue    | defaultValue |
| ---------- | -------- | ----------- | ------------ |
| nrOfImages | 1        | 5           | 1            |
| cfgScale   | 1.1      | 10          | 6.5          |
| seed       | 0        | 858_993_459 | 12           |

#### TEXT_IMAGE

| parameter      | maxLength |
| -------------- | --------- |
| prompt         | 1_024     |
| negativePrompt | 1_024     |

#### Conditioned TEXT_IMAGE

| parameter  | minValue | maxValue | defaultValue |
| ---------- | -------- | -------- | ------------ |
| similarity | 0        | 1.0      | 0.7          |

#### IMAGE_VARIATION
| parameter  | minValue | maxValue | defaultValue |
| ---------- | -------- | -------- | ------------ |
| similarity | 0.2      | 1.0      | ???          |
| images     | 1        | 5        | ???          |

| parameter      | maxLength |
| -------------- | --------- |
| prompt         | 1_024     |
| negativePrompt | 1_024     |


#### COLOR_GUIDED_GENERATION

| parameter      | maxLength |
| -------------- | --------- |
| prompt         | 1_024     |
| negativePrompt | 1_024     |
| colors         | 10        |

#### TO DO
| parameter | minValue | maxValue | defaultValue |
| --------- | -------- | -------- | ------------ |


| parameter | maxLength |
| --------- | --------- |


### Titan 

[user guide](https://docs.aws.amazon.com/bedrock/latest/userguide/model-parameters-titan-image.html)

#### Algemeen
| parameter  | minValue | maxValue      | defaultValue |
| ---------- | -------- | ------------- | ------------ |
| nrOfImages | 1        | 5             | 1            |
| cfgScale   | 1.1      | 10.0          | 8.0          |
| seed       | 0        | 2_147_483_646 | 42           |

#### TEXT_IMAGE

| parameter      | maxLength |
| -------------- | --------- |
| prompt         | 512       |
| negativePrompt | 512       |

#### Conditioned TEXT_IMAGE

| parameter  | minValue | maxValue | defaultValue |
| ---------- | -------- | -------- | ------------ |
| similarity | 0        | 1.0      | 0.7          |

#### IMAGE_VARIATION
| parameter  | minValue | maxValue | defaultValue |
| ---------- | -------- | -------- | ------------ |
| similarity | 0.2      | 1.0      | 0.7          |
| images     | 1        | 5        | ???          |

| parameter      | maxLength |
| -------------- | --------- |
| prompt         | 512       |
| negativePrompt | 512       |

#### COLOR_GUIDED_GENERATION

| parameter      | maxLength |
| -------------- | --------- |
| prompt         | 512       |
| negativePrompt | 512       |
| colors         | 10        |

