import React, { Component, useEffect } from 'react';
import { connect, useSelector, useDispatch, useActions } from 'react-redux';
import { reduxForm, Field } from 'redux-form';
import { createWater } from '../actions';
import { bindActionCreators } from 'redux';
import { fetchTenants, fetchBuildings, fetchCompanies } from '../actions';
import { useState, useCallback} from 'react'
import {useDropzone} from 'react-dropzone'
import Dropzone from 'react-dropzone'
import {Image} from 'cloudinary-react';
import { useForm } from 'react-hook-form';
import { useHistory } from "react-router";
import axios from 'axios';
import ProgressBar from 'react-bootstrap/ProgressBar';
import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';

let schema = yup.object().shape({
  submission_date: yup.date().required(),
  quantity: yup.number().required(),
});

const WaterNew = () => {

  // History hook
  const history = useHistory();

  // React hooks for uploading file
  const [uploadedFiles, setUploadedFiles] = useState([]);

  // React hooks for progress bar
  const [uploadPercentage, setUploadPercentage] = useState(0);
  const [companySelected, setCompanySelected ] = useState("Toutes les sociétés");
  const [buildingSelected, setBuildingSelected ] = useState("Tous les immeubles");
  const [tenantSelected, setTenantSelected ] = useState("");

  // MapDispatchToProp hook
  const dispatch = useDispatch()

  // MapStateToProp hook for tenants
  const tenants = useSelector( state => state.tenants)
  const companies = useSelector( state => state.companies)
  const buildings = useSelector( state => state.buildings)

  // ComponentDidMount hook to retrieve tenants, companies, buildings info from redux
  useEffect(() => {
    dispatch(fetchTenants());
    dispatch(fetchCompanies());
    dispatch(fetchBuildings());
  }, []);

  // Upload to Cloudinary
  const onDrop = useCallback(acceptedFiles => {
    const url = `https://api.cloudinary.com/v1_1/${ process.env.REACT_APP_CLOUDINARY_API}/upload`

    // Upload percentage calculation
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
        process.env.REACT_APP_CLOUDINARY_PRESET
        // "vj7q0nmq"
      );

      // post requrest via axios
      axios.post(url, formData, options ).then(response => {
        const data = response.data;
        setUploadPercentage(0)
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
  const { register, handleSubmit, errors } = useForm({
    resolver: yupResolver(schema),
  });

  // Call API and post data from form
  const onSubmit = (data) => {
    const isValid = schema.isValid(data)
    console.log(data)
    console.log(isValid)
    // createWater(data, (post) => {
    //   history.push('/waters'); // Navigate after submit
    //   return post;
    // });
  }

  // Set the state of the company
  const setCompany = (event) => {
    setCompanySelected(event.target.value)
    setBuildingSelected("Tous les immeubles")
  }

  // Set the state of the building
  const setBuilding = (event) => {
    setBuildingSelected(event.target.value)
  }

  // Set the state of the tenant
  const setTenant = (event) => {
    setTenantSelected(event.target.value)
  }

  // Display all the companies in the form select
  const renderCompanies = (companies) => {
    return companies.map((company) => {
      return company.map((c) => {
        return (
          <option value={c.name} key={c.id}>{c.name}</option>
        );
      })
    })
  }

    // Display all the buildings in the form select
  const renderBuildings = (buildings) => {
    let buildingsArray = []
    // Check company field and select buildings
    if (companySelected === "Toutes les sociétés") {
      buildings.forEach((building) => {
        building.forEach((b) => {
          buildingsArray.push(b)
        })
      })
    } else if (companySelected != "Toutes les sociétés") {
      buildings.forEach((building) => {
        building.forEach((b) => {
          if (b.company_name === companySelected) {
            buildingsArray.push(b)
          }
        })
      })
    }
    return buildingsArray.map((b) => {
      return (
        <option value={b.name} key={b.id}>{b.name}</option>
      );
    })
  }

  // Display all the tenants in the form select
  const renderTenants = (tenants) => {
    let tenantsArray = []
    // Check selection and select tenants
    // toutes les sociétés AND tous les immeubles
    if (companySelected === "Toutes les sociétés" && buildingSelected === "Tous les immeubles") {
      tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          tenantsArray.push(t)
        })
      })
    }
    // NOT toutes les sociétés AND tous les immeubles
    else if (companySelected != "Toutes les sociétés" && buildingSelected === "Tous les immeubles") {
      tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          if (companySelected === t.company_name) {
            tenantsArray.push(t)
          }
        })
      })
    }
    // toutes les sociétés NOT tous les immeubles
    else if (companySelected === "Toutes les sociétés" && buildingSelected != "Tous les immeubles") {
      tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          if (buildingSelected === t.building_name) {
            tenantsArray.push(t)
          }
        })
      })
    }
    // NOT toutes les sociétés NOT tous les immeubles
    else if (companySelected != "Toutes les sociétés" && buildingSelected != "Tous les immeubles") {
      tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          if (companySelected === t.company_name && buildingSelected === t.building_name) {
            tenantsArray.push(t)
          }
        })
      })
    }

    return tenantsArray.map((t) => {
      return (
        <option value={t.id} key={t.id}>{t.first_name} {t.last_name}</option>
      );
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
          <label htmlFor="date" className="mt-3">Date *</label>
          <input
              ref={register}
              className="form-control"
              label="Date"
              name="submission_date"
              type="date"
              required=""
          />
          <p className="mt-2" style={{color: "red", fontSize: "12px"}}>{errors["submission_date"]?.message}</p>
          <div>
            <label htmlFor="company_id" className="">Sélectionnez une société</label>
            <select
              ref={register}
              className="form-control"
              label="Company_id"
              name="company_id"
              type="text"
              value={companySelected}
              onChange={c => setCompany(c)}>
               <option value="Toutes les sociétés" key="01">Toutes les sociétés</option>
               <option value="n/a - détention en nom propre" key="02">n/a - détention en nom propre</option>
               {renderCompanies(companies)}
            </select>
          </div>
          <div>
            <label htmlFor="building_id" className=" mt-3">Sélectionnez un immeuble</label>
            <select
              ref={register}
              className="form-control"
              label="Building_id"
              name="building_id"
              type="text"
              value={buildingSelected}
              onChange={b => setBuilding(b)}>
                <option value="Tous les immeubles" key="01">Tous les immeubles</option>
                <option value="n/a - aucun immeuble" key="02">n/a - aucun immeuble</option>
               {renderBuildings(buildings)}
            </select>
          </div>
          <div>
            <label htmlFor="tenant_id" className=" mt-3">Sélectionnez un locataire</label>
            <select
              ref={register}
              className="form-control"
              label="Tenant_id"
              name="tenant_id"
              type="text"
              value={tenantSelected}
              onChange={t => setTenant(t)}>
               {renderTenants(tenants)}
            </select>
          </div>
          <div className="mt-3">
            <label htmlFor="quantity">Quantité *</label>
             <input
               ref={register}
               className="form-control"
               label="Quantity"
               name="quantity"
               type="text"
               rows="8"
             />
             <p className="mt-2" style={{color: "red", fontSize: "12px"}}>{errors["quantity"]?.message}</p>
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
                <div className="text-center">
                  <div><i style={{fontSize: "30px", color:"#4285F4"}} className="fas fa-cloud-upload-alt"></i></div>
                  <p style={{color: "#4285F4"}}>Déposez le fichier pour l'importer</p>
                </div> :
                <div className="text-center" style={{cursor: "pointer"}}>
                  <div><i style={{fontSize: "30px", color:"#4285F4", opacity: "0.8"}} className="fas fa-cloud-upload-alt"></i></div>
                  <p>Déposez des fichiers ici ou cliquez pour charger.</p>
                </div>
              }
            </div>
            <div className="mt-3">{ uploadPercentage > 0 ? progressInstance : null }</div>
            <ul className="mt-3">
              {uploadedFiles.map((file) => (
                <li key={file.public_id}>
                  <Image
                    cloudName={process.env.REACT_APP_CLOUDINARY_API}
                    publicId={file.public_id}
                    className="imageUpload mb-1"
                    style={{width: "50px"}}
                  />
                  <span
                    className="text-primary cursor-pointer ml-3 fas fa-times"
                    style={{cursor: "pointer", color: "red"}}
                    onClick={() => removeFile(file)}
                  >
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
          <button disabled={!isEnabled} className="btn btn-yellow-mustard" onSubmit={() => dispatch(createWater())}>Valider</button>
        </form>
      </div>
    </div>
  )
}

export default WaterNew;






