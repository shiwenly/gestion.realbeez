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
    const fd = new FormData();
    fd.append("photo", values);
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
      <div>
        <form onSubmit={this.props.handleSubmit(this.onSubmit)}>
          <Field
              label="Submission_date"
              name="submission_date"
              type="date"
              component={this.renderField}
          />
          <label>Locataire</label>
            <div>
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
          <label htmlFor="quantity">Quantité</label>
           <Field
             className="form-control"
             label="Quantity"
             name="quantity"
             type="text"
             component="input"
             rows="8"
           />
          <label htmlFor="photo">Pièce jointe</label>
           <Field
             className="form-control"
             label="Photo"
             name="photo"
             type="file"
             component={WaterDropzone}
             // photo={this.props.fileUploaded()}
             // handleOnDrop={this.handleOnDrop}
             rows="8"
           />
          <button className="btn btn-primary" type="submit"
            disabled={this.props.pristine || this.props.submitting}>
             Create Post
            </button>
        </form>
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
