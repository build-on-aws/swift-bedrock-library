"use client";
import Image from 'next/image';

export default function Human({text, image}) {
    return (
        <div className="col-start-3 col-end-13 p-3 rounded-lg">
            <div className="flex items-center justify-start flex-row-reverse">
                <div
                    className="flex items-center justify-center h-10 w-10 rounded-full bg-indigo-500 flex-shrink-0"
                >
                    H
                </div>
                <div
                    className="relative mr-3 text-sm bg-indigo-100 py-2 px-4 shadow rounded-xl"
                >
                    <div>{text}</div>
                    {image && (
                        <div className="mt-3">
                            <Image 
                                src={image} 
                                alt="Attached image" 
                                width={200} 
                                height={200} 
                                className="rounded-lg"
                            />
                        </div>
                    )}
                </div>
            </div>
        </div>
    )
}
