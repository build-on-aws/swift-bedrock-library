import React, { useState } from 'react';
import Image from 'next/image';
import Spinner from "@/components/Spinner";
// import StyleSelector from "@/components/imagePlayground/StyleSelector";
import GlobalConfig from "@/app/app.config";
import ImageModelSelector from "./ImageModelSelector";
import { defaultImageModel } from "@/helpers/imageModelData";
import NumericInput from "../NumericInput";

export default function ImageContainer() {
    const [imgSrc, setImgSrc] = useState(['/placeholder.png']);
    const [inputValue, setInputValue] = useState('');
    // const [stylePreset, setStylePreset] = useState('no style');
    const [isLoading, setIsLoading] = useState(false);
    const [selectedModel, setSelectedModel] = useState(defaultImageModel);
    const [nrOfImages, setNrOfImages] = useState(1);
    const [errorMessage, setErrorMessage] = useState(null);


    const onModelChange = (newModel) => {
        setSelectedModel(newModel);
        // setInputValue("");
    }

    // const handleStyleChange = (newStyle) => {
    //     setStylePreset(newStyle);
    // };

    const handleInputChange = (e) => {
        setInputValue(e.target.value);
    };

    const handleNrOfImagesChange = (value) => {
        setNrOfImages(value);
    };

    const sendMessage = async () => {
        const endpoint = `/foundation-models/image/${selectedModel.modelId}`;
        const api = `${GlobalConfig.apiHost}:${GlobalConfig.apiPort}${endpoint}`;

        if (inputValue.trim() === '') { return; }

        setIsLoading(true);
        setErrorMessage(null);

        // if (stylePreset === "no style") {
        //     setStylePreset("");
        // }

        const prompt = {
            prompt: inputValue.trim(),
            nrOfImages: parseInt(nrOfImages, 10),
            // stylePreset: stylePreset
        }

        try {
            const response = await fetch(api, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(prompt)
            });

            if (!response.ok) {
                await response.json().then(data => {
                    console.log(data)
                    console.log(data.error.message)
                    let errorMsg = data.error.message
                    setErrorMessage(errorMsg);
                    throw new Error(errorMsg);
                });
            }

            const body = await response.json();

            const images = body.images.map(img => `data:image/png;base64,${img}`);
            setImgSrc(images);

        } catch (error) {
            console.error('Error fetching image:', error);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="flex flex-col flex-auto h-full p-6">
            <h3 className="text-3xl font-medium text-gray-700">Image Playground</h3>
            <div className="flex flex-col flex-auto flex-shrink-0 rounded-2xl bg-gray-100 p-4 mt-8">
                <ImageModelSelector model={selectedModel} onModelChange={onModelChange} />
                <div className="flex flex-row items-center h-16 rounded-xl bg-white w-full px-4">
                    <div className="flex-grow">
                        <div className="relative w-full">
                            <input
                                type="text"
                                value={inputValue}
                                onChange={handleInputChange}
                                onKeyPress={(event) => {
                                    if (event.key === 'Enter') {
                                        sendMessage();
                                    }
                                }}
                                placeholder="Image prompt"
                                className="flex w-full border rounded-xl focus:outline-none focus:border-indigo-300 pl-4 h-10" />
                        </div>
                    </div>
                    {/* <StyleSelector onStyleChange={handleStyleChange} /> */}

                    <div className="ml-4">
                        <div className="relative">
                            <label htmlFor="nrOfImages">
                                Number of images:
                            </label>
                        </div>
                    </div>
                    <div className="ml-4">
                        <NumericInput
                            className="relative w-20"
                            placeholder="1"
                            value={nrOfImages}
                            range={{ min: 1, max: 5, default: 1 }}
                            disabled={isLoading}
                            callback={handleNrOfImagesChange}
                        />
                    </div>

                    <div className="ml-4">
                        <button
                            type="button"
                            onClick={sendMessage}
                            className="flex items-center justify-center bg-indigo-500 hover:bg-indigo-600 rounded-xl text-white px-4 py-1 flex-shrink-0"
                        >
                            <span>Create image</span>
                            <span className="ml-2">
                                <svg
                                    className="w-4 h-4 transform rotate-45 -mt-px"
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                    xmlns="http://www.w3.org/2000/svg"
                                >
                                    <path
                                        strokeLinecap="round"
                                        strokeLinejoin="round"
                                        strokeWidth="2"
                                        d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                                    ></path>
                                </svg>
                            </span>
                        </button>
                    </div>
                </div>
                {/* Error message display */}
                {errorMessage && (
                    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-xl mb-4 relative" role="alert">
                        <strong className="font-bold">Error: </strong>
                        <span className="block sm:inline whitespace-pre-wrap">{errorMessage}</span>
                        <button
                            className="absolute top-0 bottom-0 right-0 px-4 py-3"
                            onClick={() => setErrorMessage(null)}
                        >
                            <span className="text-red-500">×</span>
                        </button>
                    </div>
                )}

                {/* images */}
                <div className="flex flex-col h-full overflow-x-auto mb-4">
                    <div className="flex flex-col h-full">
                        <div className="grid grid-cols-12 gap-y-2">
                            <div className="col-start-1 col-end-11 p-3 rounded-lg">
                                <div className="grid grid-cols-[repeat(auto-fit,minmax(512px,1fr))] gap-4 justify-items-center">
                                    {isLoading ? (
                                        <Spinner />
                                    ) : (
                                        imgSrc.map((src, index) => (
                                            <div key={index} className="flex justify-center">
                                                <Image
                                                    src={src}
                                                    alt={`AI generated image ${index + 1}`}
                                                    width="512"
                                                    height="512"
                                                />
                                            </div>
                                        ))
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    )
}