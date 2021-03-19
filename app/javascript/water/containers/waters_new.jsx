import React, { Component } from 'react';
import { connect } from 'react-redux';
import { reduxForm, Field } from 'redux-form';
import { createWater } from '../actions';
import { bindActionCreators } from 'redux';
import { fetchTenants } from '../actions';
import { useState, useCallback} from 'react';
import {useDropzone} from 'react-dropzone';
import Dropzone from 'react-dropzone';
import WaterDropzone from './water_dropzone';
import { fileUploaded } from '../actions/index';

class WatersNew extends Component {

  // state = { photo: [] };

  componentDidMount() {
    this.props.fetchTenants();
  }

  onSubmit = (values) => {
    // const imageUpload = document.querySelector(".imageUpload").src;
    // const fd = new FormData();
    // fd.append("photo", imageUpload);
    // fd.append("submission_date", submission_date);
    // fd.append("quantity", quantity);
    // fd.append("tenant_id", tenant_id);
    this.props.createWater(values, (post) => {
      this.props.history.push('/waters'); // Navigate after submit
      return post;
    });
  }

  // handleOnDrop = (newImageFile) => this.setState({ photo: newImageFile });

  renderField(field) {
    return (
      <div className="form-group">
        <label>{field.label}</label>
        <input
          className="form-control"
          type={field.type}
          {...field.input}
        />
      </div>
    );
  }

  renderPosts() {
    const tenants = this.props.tenants

    return tenants.map((tenant) => {
      return tenant.map((t) => {
        return (
          <option value={t.id} key={t.id}>{t.first_name} {t.last_name}</option>
        );
      })
    })
  }

  render() {
    return (
      <div className="row justify-content-center mt-5">
        <div className="col-12 col-md-6">
        <h3 className="text-center mb-5" style={{}}>Déclarer ma consommation d'eau</h3>
          <form onSubmit={this.props.handleSubmit(this.onSubmit)}>
            <Field
                label="Date"
                name="submission_date"
                type="date"
                component={this.renderField}
            />
            <div className="mt-3">
              <label>Locataire</label>
                <Field
                className="form-control"
                label="Tenant_id"
                name="tenant_id"
                type="text"
                component="select"
                rows="8"
                >
                  {this.renderPosts()}
                </Field>
            </div>
            <div className="mt-3">
              <label htmlFor="quantity">Quantité</label>
               <Field
                 className="form-control"
                 label="Quantity"
                 name="quantity"
                 type="text"
                 component="input"
                 rows="8"
               />
            </div>
            <div className="mt-3">
              <label htmlFor="photo">Pièce jointe</label>
               <Field
                 className="form-control"
                 label="Photo"
                 name="photo"
                 type="file"
                 component={WaterDropzone}
                 // photo={document.querySelector(".imageUpload").src}
                 values={document.querySelector(".imageUpload")}
                 // handleOnDrop={this.handleOnDrop}
                 rows="8"
               />
            </div>
            <button className="btn btn-yellow-mustard mt-4" type="submit"
              disabled={this.props.pristine || this.props.submitting}>
               Create Post
              </button>
          </form>
        </div>
      </div>
    );
  }
}

function mapStateToProps(state) {
  return {
    tenants: state.tenants
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ fetchTenants, createWater, fileUploaded }, dispatch);
}

const Example = connect(
  mapStateToProps,
  mapDispatchToProps,
)(WatersNew)

export default reduxForm({
  form: 'formWater' // a unique name for this form
})(Example)

