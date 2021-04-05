import React, { Component } from 'react';
import { Controller } from 'react-hook-form'
import Dropzone from 'react-dropzone'

import { connect } from 'react-redux';
import { reduxForm, Field } from 'redux-form';
// import { createWater } from '../actions';
import { bindActionCreators } from 'redux';
// import { fetchTenants } from '../actions';
import { useState, useCallback} from 'react'
import {useDropzone} from 'react-dropzone'
import { fileUploaded } from '../actions/index';
import {Image} from 'cloudinary-react';

export const FileInput = ({control, name}) => {

  const [uploadedFiles, setUploadedFiles] = useState([])

  const {getRootProps, getInputProps, isDragActive} = useDropzone({onDrop,
    accepts: "image.*",
    multiple: true,
  })

  const onDrop = useCallback(acceptedFiles => {
    const url = `https://api.cloudinary.com/v1_1/${ process.env.CLOUDINARY_API}/upload`

    acceptedFiles.forEach(async (acceptedFile) => {

      const formData = new FormData();
      formData.append("file", acceptedFile);
      formData.append(
        "upload_preset",
        process.env.CLOUDINARY_PRESET
      );

      const response = await fetch(url, {
        method: "post",
        body: formData,
      })

      const data = await response.json();
      console.log(data)
      setUploadedFiles(old => [...old, data])
    })
  }, [])

  return(
    <Controller
      control={control}
      name={name}
      defaultValue={[]}
      render={(onChange, onBlur, value) => (
        <Dropzone onDrop={acceptedFiles => console.log(acceptedFiles)}>
          {({getRootProps, getInputProps}) => (
            <section>
              <div {...getRootProps()} className="dropzone">
                <input {...getInputProps()}/>
                <p>Drag 'n' drop some files here, or click to select files</p>
              </div>
            </section>
          )}
        </Dropzone>
      )}
    />
  )
}

