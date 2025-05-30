export const defaultModel = {
    modelName: "Claude V3.7 Sonnet",
    modelId: "us.anthropic.claude-3-7-sonnet-20250219-v1:0",
    topKRange: {
        max: 500,
        default: 0,
        min: 0
    },
    temperatureRange: {
        min: 0,
        max: 1,
        default: 1
    },
    topPRange: {
        min: 0,
        default: 0.999,
        max: 1
    },
    maxTokenRange: {
        min: 1,
        default: 8192,
        max: 8192
    },
    maxReasoningTokensRange: {
        min: 1024,
        default: 4096,
        max: 8191
    }
}

export const models = [
    defaultModel,
    // {
    //     modelName: "Deep Seek",
    //     modelId: "us.deepseek.r1-v1:0",
    //     topPRange: {
    //         max: 1,
    //         default: 1,
    //         min: 0
    //     },
    //     temperatureRange: {
    //         default: 1,
    //         min: 0,
    //         max: 1
    //     },
    //     maxTokenRange: {
    //         max: 32768,
    //         default: 32768,
    //         min: 1
    //     },
    // },
]

export const defaultPayload = {
    prompt: "",
    temperature: defaultModel.temperatureRange.default,
    maxTokens: defaultModel.maxTokenRange.default
}