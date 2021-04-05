import React, { Component } from 'react';
import { connect } from 'react-redux';
import { reduxForm, Field } from 'redux-form';
// import { createWater } from '../actions';
import { bindActionCreators } from 'redux';
// import { fetchTenants } from '../actions';
import { useState, useCallback} from 'react'
import {useDropzone} from 'react-dropzone'
import Dropzone from 'react-dropzone'
import { fileUploaded } from '../actions/index';
import {Image} from 'cloudinary-react';

function WaterDropzone() {

  const [uploadedFiles, setUploadedFiles] = useState([])
  // const cloudinary = require('cloudinary').v2;

  const onDrop = useCallback(acceptedFiles => {
    const url = `https://api.cloudinary.com/v1_1/${ process.env.CLOUDINARY_API}/upload`

    acceptedFiles.forEach(async (acceptedFile) => {

      // const {signature, timestamp} = await getSignature();

      // Get the timestamp in seconds
      // const timestamp = Math.round((new Date).getTime()/1000);

      // Get the signature using the Node.js SDK method api_sign_request
      // const signature = cloudinary.utils.api_sign_request({
      //     timestamp: timestamp,
      //     eager: 'w_400,h_300,c_pad|w_260,h_200,c_crop',
      //     public_id: 'sample_image'},
      //   process.env.CLOUDINARY_SECRET);

      const formData = new FormData();
      formData.append("file", acceptedFile);
      formData.append(
        "upload_preset",
        process.env.CLOUDINARY_PRESET
      );
      // formData.append("signature", signature);
      // formData.append("timestamp", timestamp);
      // formData.append("api_key", process.env.CLOUDINARY_KEY);

      const response = await fetch(url, {
        method: "post",
        body: formData,
      })

      const data = await response.json();
      console.log(data)
      setUploadedFiles(old => [...old, data])
    })
  }, [])

  const {getRootProps, getInputProps, isDragActive} = useDropzone({onDrop,
    accepts: "image.*",
    multiple: true,
  })

  return (
    <div>
      <div {...getRootProps()} className="dropzone">
        <input {...getInputProps()} />
        {
          isDragActive ?
            <p>Drop the files here ...</p> :
            <p>Drag 'n' drop some files here, or click to select files</p>
        }
      </div>
      <ul className="mt-3">
        {uploadedFiles.map((file) => (
          <li key={file.public_id}>
            <Image
            cloudName={process.env.CLOUDINARY_API}
            publicId={file.public_id}
            className="imageUpload"
            width="300"
            crop="scale"
            />
          </li>
          ))}
      </ul>
    </div>
  )
}

// function mapStateToProps(state) {
//   return { file: state.file };
// }

// function mapDispatchToProps(dispatch) {
//   return bindActionCreators({ fileUploaded }, dispatch)
//     // fileUploaded: (file) => dispatch(actions.fileUploaded(file))
// }

export default WaterDropzone;

// async function getSignature() {
//   const response = await fetch("..components/pages/api/sign");
//   const data = await response.json();
//   const { signature, timestamp } = data;
//   return { signature, timestamp };
// }
