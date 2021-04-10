import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux';
import { fetchWaters } from '../actions/index';
import { fetchCompanies } from '../actions/index';
import { fetchBuildings } from '../actions/index';
import {Image} from 'cloudinary-react';

class WatersIndex extends Component {

  constructor(props) {
   super(props);
   this.state = {
    company: 'Toutes les sociétés',
    building: 'Tous les immeubles',
  };
   this.handleChangeCompany = this.handleChangeCompany.bind(this);
   this.handleChangeBuilding = this.handleChangeBuilding.bind(this);
   this.handleSubmit = this.handleSubmit.bind(this);

  }

  componentDidMount() {
    if (!this.fetchWaters) {
      this.props.fetchWaters();
    }
    if (!this.fetchCompanies) {
      this.props.fetchCompanies();
    }
    if (!this.fetchBuildings) {
      this.props.fetchBuildings();
    }
  }


  handleChangeCompany(event) {
    this.setState({company: event.target.value});
    this.setState({building: 'Tous les immeubles'});
  }

  handleChangeBuilding(event) {
    this.setState({building: event.target.value});
  }

  handleSubmit(event) {
   // alert('A name was submitted: ' + this.state.value);
   // event.preventDefault();
  }

  renderTableData() {
    let watersArray = []

    if (this.state.company === "Toutes les sociétés" && this.state.building === "Tous les immeubles") {
      console.log(this.state.company + " " + this.state.building)
      // const watersArray = [this.props.waters]
      watersArray = this.props.waters
    } else if (this.state.company != "Toutes les sociétés" && this.state.building === "Tous les immeubles") {
      watersArray = this.props.waters.filter((w) => w.company_name === this.state.company)
    } else if (this.state.company === "Toutes les sociétés" && this.state.building != "Tous les immeubles") {
      watersArray = this.props.waters.filter((w) => w.building_name === this.state.building)
    } else if (this.state.company != "Toutes les sociétés" && this.state.building != "Tous les immeubles") {
      watersArray = this.props.waters.filter((w) => w.company_name === this.state.company && w.building_name === this.state.building)
    }

    return watersArray.map((water, index) => {
      const { id, submission_date, quantity, tenant_name, building_name, company_name, photo } = water //destructuring
      const photo_array = photo.split(',')
        return (
          <tr key={id}>
             <td>{submission_date}</td>
             <td>{company_name}</td>
             <td>{building_name}</td>
             <td>{tenant_name}</td>
             <td>{quantity}</td>
             <td>{photo_array.map((p, index) =>
              <a key={index} className="btn-transparent mx-1" style={{fontSize:'12px'}} target="_blank" href={p}>Ouvrir</a>
              )}
             </td>
          </tr>
        )
    })
  }

  renderTableHeader() {
     let header = ['Date', "Société", "Immeuble", "Locataire", "Consommation", "Pièce jointe"]
     return header.map((key, index) => {
        return <th  key={index}>{key}</th>
     })
  }

  renderWaters() {
    // return this.props.waters.map((water) => {
      return (
        <div style={{overflow: 'scroll'}}>
          <table id='waters' className='mt-0' style={{backgroundColor: 'white'}} >
             <tbody>
                <tr>{this.renderTableHeader()}</tr>
                 {this.renderTableData()}
             </tbody>
          </table>
        </div>
      );
    // });
  }

    // Display all the company in the form select
  renderCompany() {
    // return tenants.map((tenant) => {
      return this.props.companies.map((company) => {
        return company.map((c) => {
          return (
            <option value={c.name} key={c.id}>{c.name}</option>
          );
        })
      })
    // })
  }

  renderBuilding() {
    return this.props.buildings.map((building) => {
      return building.map((b) => {
        if (this.state.company === '' || this.state.company === "Toutes les sociétés") {
          return (
            <option value={b.name} key={b.id}>{b.name}</option>
          );
        } else if (this.state.company === b.company_name) {
          return (
            <option value={b.name} key={b.id}>{b.name}</option>
          );
        }
      })
    })
  }

  render() {
    return (
      <div className="" style={{fontSize: '12px' }}>
        <h3 className="text-center mt-5 mb-5" style={{color: '#D8A727', fontFamily: 'Simply Rounded', letterSpacing: '1px'}}>Consommation d'eau</h3>
        <div className="first-row">
          <form className="" onSubmit={this.handleSubmit}>
            <div className="row mb-3">
              <div className="col-9 col-md-3 pr-0 mt-1">
                <select
                  className="form-control"
                  label="Company"
                  name="company"
                  type="text"
                  value={this.state.company}
                  onChange={this.handleChangeCompany}
                >
                  <option value={"Toutes les sociétés"} key="01">Toutes les sociétés</option>
                  <option value={"n/a - détention en nom propre"} key="02">n/a - détention en nom propre</option>
                  {this.renderCompany()}
                </select>
              </div>
              <div className="col-9 col-md-3 pr-0 mt-1">
                <select
                  className="form-control"
                  label="Building"
                  name="building"
                  type="text"
                  value={this.state.building}
                  onChange={this.handleChangeBuilding}
                >
                  <option value={"Tous les immeubles"} key="01">Tous les immeubles</option>
                  <option value={"n/a - aucun immeuble"} key="02">n/a - aucun immeuble</option>
                  {this.renderBuilding()}
                </select>
              </div>
            </div>
          </form>
          <h5 className="border-top pt-3"></h5>
          <div className="mt-2 mb-4">
            <Link className="btn btn-transparent-bold" to="/waters/new">
             Déclarer ma consommation
            </Link>
          </div>
        </div>
        {this.renderWaters()}
      </div>
    );
  }
}

function mapStateToProps(state) {
  return {
    waters: state.waters ,
    companies: state.companies,
    buildings: state.buildings
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ fetchWaters, fetchCompanies, fetchBuildings }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(WatersIndex);


// const Example = connect(
//   mapStateToProps,
//   mapDispatchToProps,
// )(WatersIndex)

// export default reduxForm({
//   form: 'formWaters' // a unique name for this form
// })(Example)
