import React, { Component, useEffect } from 'react';
import { connect, useSelector, useDispatch, useActions } from 'react-redux';
import { reduxForm, Field } from 'redux-form';
import { createWater } from '../actions';
import { bindActionCreators } from 'redux';
import { fetchTenants } from '../actions';
import { useState, useCallback} from 'react'
import {useDropzone} from 'react-dropzone'
import Dropzone from 'react-dropzone'
import {Image} from 'cloudinary-react';
import { useForm } from 'react-hook-form';
import { useHistory } from "react-router";
import axios from 'axios';
import ProgressBar from 'react-bootstrap/ProgressBar'
// import { fileUploaded } from '../actions/index';

const WaterDropzone = () => {

  const TENANT_URL = '/api/v1/tenants'

  // History hook
  const history = useHistory();

  // TO DO : Need to modify with functional component !!!
  // const componentDidMount = () => {
  //   this.props.fetchTenants();
  // }

  // React hooks for uploading file
  const [uploadedFiles, setUploadedFiles] = useState([]);

  // React hooks for progress bar
  const [uploadPercentage, setUploadPercentage] = useState(0);

  // MapDispatchToProp hook
  const dispatch = useDispatch()

  // MapStateToProp hook for tenants
  const tenants = useSelector( state => state.tenants)
  // console.log(tenants)

  // ComponentDidMount hook to retrieve tenants info from redux
  useEffect(() => {
       dispatch(fetchTenants());
  }, []);

  // Upload to Cloudinary
  const onDrop = useCallback(acceptedFiles => {
    const url = `https://api.cloudinary.com/v1_1/${ process.env.CLOUDINARY_API}/upload`

    // Uploar percentage calculation
    const options = {
      onUploadProgress: (progressEvent) => {
        const {loaded, total} = progressEvent;
        let percent = Math.floor(loaded * 100 / total )
        // console.log( `${loaded}kb of ${total}kb | ${percent}%`)
        setUploadPercentage(percent)
      }
    }

    acceptedFiles.forEach(async (acceptedFile) => {

      const formData = new FormData();
      formData.append("file", acceptedFile);
      formData.append(
        "upload_preset",
        process.env.CLOUDINARY_PRESET
      );

      // const response = await fetch(url, {
      //   method: "post",
      //   body: formData,
      // })

      // post requrest via axios
      axios.post(url, formData, options ).then(response => {
        // console.log(response)
        const data = response.data;
        setUploadPercentage(0)
        // console.log(uploadPercentage)
        // console.log(data)
        setUploadedFiles(old => [...old, data])
      })
    })
  }, [])

  // Dropzone hook
  const {getRootProps, getInputProps, isDragActive} = useDropzone({onDrop,
    accepts: "image.*",
    multiple: true,
  })

  // React form hook
  const {register, handleSubmit} = useForm()

  // Call API and post data from form
  const onSubmit = (data) => {
    // const ROOT_URL = '../api/v1/waters';
    // const response = fetch(ROOT_URL, {
    //   method: 'POST',
    //   headers: {
    //     'Accept': 'application/json',
    //     'Content-Type': 'application/json'
    //   },
    //   credentials: 'same-origin',
    //   body: JSON.stringify(data)
    // }).then(response => response.json())
    //   // .then(callback);
    //   history.push("/waters");
    createWater(data, (post) => {
      history.push('/waters'); // Navigate after submit
      return post;
    });
  }

  // Display all the tenants in the form select
  const renderPosts = (tenants) => {
    return tenants.map((tenant) => {
      return tenant.map((t) => {
        return (
          <option value={t.id} key={t.id}>{t.first_name} {t.last_name}</option>
        );
      })
    })
  }

  // react-bootstrap progress bar
  const progressInstance = <ProgressBar now={uploadPercentage} label={`${uploadPercentage}%`} />;

  // disable submit button if file is being uploaded
  const isEnabled = uploadPercentage === 0;

  // Remove file uploaded
  const removeFile = (file) => {
    const index = uploadedFiles.findIndex(f => f === file)
    uploadedFiles.splice(index, 1)
    setUploadedFiles(old => [...old])
  }

  // React Form
  return (
    <div className="row justify-content-center mt-5">
      <div className="col-12 col-md-6">
      <h3 className="text-center mb-5" style={{}}>Déclarer ma consommation d'eau</h3>
        <form onSubmit={handleSubmit(onSubmit)}>
          <label htmlFor="date" className="mt-3">Date</label>
          <input
              ref={register}
              className="form-control"
              label="Date"
              name="submission_date"
              type="date"
          />
          <div>
            <label htmlFor="tenant_id" className=" mt-3">Locataire</label>
            <select
              // onClick={() => dispatch(fetchTenants())}
              ref={register}
              className="form-control"
              label="Tenant_id"
              name="tenant_id"
              type="text"
              defaultValue="">
               {renderPosts(tenants)}
            </select>
          </div>
          <div className="mt-3">
            <label htmlFor="quantity">Quantité</label>
             <input
               ref={register}
               className="form-control"
               label="Quantity"
               name="quantity"
               type="text"
               rows="8"
             />
          </div>
          <div>
            <p className="mt-3 mb-2" >Pièce jointe</p>
            <div {...getRootProps()} className="dropzone">
              <input
                label="picture"
                name="picture"
                type="file"
                {...getInputProps()}
              />

              {
                isDragActive ?
                  <p>Drop the files here ...</p> :
                  <p>Drag 'n' drop some files here, or click to select files</p>
              }
            </div>
            <div className="mt-3">{ uploadPercentage > 0 ? progressInstance : null }</div>
            <ul className="mt-3">
              {uploadedFiles.map((file) => (
                <li key={file.public_id}>
                  { file.original_filename }
                  <span
                    className="text-primary cursor-pointer ml-3"
                    style={{cursor: "pointer"}}
                    onClick={() => removeFile(file)}
                  >
                    supprimer
                  </span>
                </li>
                ))}
            </ul>
          </div>
          <div className="mt-3">
            <label htmlFor="photo"></label>
              <input
              ref={register}
              className="form-control"
              label="photo"
              name="photo"
              type="hidden"
              value={ uploadedFiles.map((pic) => pic.url) }
            />
          </div>
          <button disabled={!isEnabled} className="btn btn-yellow-mustard" onSubmit={() => dispatch(createWater())}>Submit</button>
        </form>
      </div>
    </div>
  )
}

// function mapStateToProps(state) {
//   return {
//     tenants: state.tenants
//   };
// }

// function mapDispatchToProps(dispatch) {
//   return bindActionCreators({ fetchTenants}, dispatch);
// }

// to display image after upload
// <Image
// cloudName={process.env.CLOUDINARY_API}
// publicId={file.public_id}
// className="imageUpload"
// width="50"
// crop="scale"
// />

// export default connect(mapStateToProps, mapDispatchToProps)(WaterDropzone);
export default WaterDropzone;


