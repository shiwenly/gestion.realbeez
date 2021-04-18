import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux';
import { fetchWaters } from '../actions/index';
import { fetchCompanies, fetchBuildings, fetchTenants, deleteWater } from '../actions/index';
import {Image} from 'cloudinary-react';

class WatersIndex extends Component {

  constructor(props) {
    super(props);
    this.state = {
      company: 'Toutes les sociétés',
      building: 'Tous les immeubles',
      tenant: 'Tous les locataires'
    };
    this.handleChangeCompany = this.handleChangeCompany.bind(this);
    this.handleChangeBuilding = this.handleChangeBuilding.bind(this);
    this.handleChangeTenant = this.handleChangeTenant.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    // this.handleRemoveWater = this.handleRemoveWater.bind(this);
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
    if (!this.fetchTenants) {
      this.props.fetchTenants();
    }
  }


  handleChangeCompany(event) {
    this.setState({company: event.target.value});
    this.setState({building: 'Tous les immeubles'});
    this.setState({tenant: 'Tous les locataires'});
  }

  handleChangeBuilding(event) {
    this.setState({building: event.target.value});
    this.setState({tenant: 'Tous les locataires'});
  }

  handleChangeTenant(event) {
    this.setState({tenant: event.target.value});
  }

  handleSubmit(event) {
   // alert('A name was submitted: ' + this.state.value);
   // event.preventDefault();
  }

  handleRemoveWater(water) {
    // console.log(water.id)
    // alert("Confirmez la suppression de la saisie?");

    this.props.deleteWater(water, (post) => {
      this.props.history.push('/waters'); // Navigate after submit
      // return post;
    });
  }

  handleUpdateWater(water) {
    // this.props.history.push(`/waters/edit/${water.id}`)

    this.props.history.push({
    pathname: `/waters/edit/${water.id}`,
    state: water // your data array of objects
    })
  }

  renderTableData() {
    let watersArray = []
    // Select the waters based on selection from user
    // Toutes les sociétés AND Tous les immeubles AND Tous les locataires
    if (this.state.company === "Toutes les sociétés" && this.state.building === "Tous les immeubles" && this.state.tenant === "Tous les locataires") {
      watersArray = this.props.waters
    }
    // Toutes les sociétés NOT Tous les immeubles AND Tous les locataires
    else if (this.state.company === "Toutes les sociétés" && this.state.building != "Tous les immeubles" && this.state.tenant === "Tous les locataires") {
      watersArray = this.props.waters.filter((w) => w.building_name === this.state.building)
    }
    // Toutes les sociétés AND Tous les immeubles NOT Tous les locataires
    else if (this.state.company === "Toutes les sociétés" && this.state.building === "Tous les immeubles" && this.state.tenant != "Tous les locataires") {
      watersArray = this.props.waters.filter((w) => w.tenant_name === this.state.tenant)
    }
    // Toutes les sociétés NOT Tous les immeubles NOT Tous les locataires
    else if (this.state.company === "Toutes les sociétés" && this.state.building != "Tous les immeubles" && this.state.tenant != "Tous les locataires") {
      watersArray = this.props.waters.filter((w) => w.building_name === this.state.building && w.tenant_name === this.state.tenant)
    }
    // NOT Toutes les sociétés AND Tous les immeubles AND Tous les locataires
    else if (this.state.company != "Toutes les sociétés" && this.state.building === "Tous les immeubles" && this.state.tenant === "Tous les locataires") {
      watersArray = this.props.waters.filter((w) => w.company_name === this.state.company)
    }
    // NOT Toutes les sociétés NOT Tous les immeubles AND Tous les locataires
    else if (this.state.company != "Toutes les sociétés" && this.state.building != "Tous les immeubles" && this.state.tenant === "Tous les locataires") {
      watersArray = this.props.waters.filter((w) => w.company_name === this.state.company && w.building_name === this.state.building)
    }
    // NOT Toutes les sociétés AND Tous les immeubles NOT Tous les locataires
    else if (this.state.company != "Toutes les sociétés" && this.state.building === "Tous les immeubles" && this.state.tenant != "Tous les locataires") {
      watersArray = this.props.waters.filter((w) => w.company_name === this.state.company && w.tenant_name === this.state.tenant)
    }
    // NOT Toutes les sociétés NOT Tous les immeubles NOT Tous les locataires
    else if (this.state.company != "Toutes les sociétés" && this.state.building != "Tous les immeubles" && this.state.tenant != "Tous les locataires") {
      watersArray = this.props.waters.filter((w) => w.company_name === this.state.company && w.building_name === this.state.building && w.tenant_name === this.state.tenant)
    }
    // else if (this.state.company != "Toutes les sociétés" && this.state.building === "Tous les immeubles") {
    //   watersArray = this.props.waters.filter((w) => w.company_name === this.state.company)
    // } else if (this.state.company === "Toutes les sociétés" && this.state.building != "Tous les immeubles") {

    // } else if (this.state.company != "Toutes les sociétés" && this.state.building != "Tous les immeubles") {
    //   watersArray = this.props.waters.filter((w) => w.company_name === this.state.company && w.building_name === this.state.building)
    // }
    // console.log(this.state.company + " " +  this.state.building + " " + this.state.tenant)
    // console.log(watersArray)

    // Display selection in table
    return watersArray.map((water, index) => {
      const { id, submission_date, quantity, tenant_name, building_name, company_name, photo } = water //destructuring
      const photoArray = photo.split(',')
      return (
        <tr key={id}>
           <td>{submission_date}</td>
           <td>{company_name}</td>
           <td>{building_name}</td>
           <td>{tenant_name}</td>
           <td>{quantity}</td>
           <td>{photoArray.map((p, index) =>
            <a key={index} className="btn-transparent mx-1" style={{fontSize:'12px'}} target="_blank" href={p}>Ouvrir</a>
            )}
           </td>
           <td>
            <button className="btn-icon fas fa-edit" onClick={() => this.handleUpdateWater(water)}>
            </button>
            {/*<button className="btn-icon fas fa-trash" onClick={() => this.handleRemoveWater(water)}>*/}
            <button className="btn-icon fas fa-trash" onClick={() => { if (window.confirm(`Confirmez-vous la suppression de la saisie du ${water.submission_date} ?`)) this.handleRemoveWater(water) }} >
            </button>
           </td>
        </tr>
      )
    })
  }

  renderTableHeader() {
     let header = ['Date', "Société", "Immeuble", "Locataire", "Consommation", "Pièce jointe", ""]
     return header.map((key, index) => {
        return <th  key={index}>{key}</th>
     })
  }

  renderWaters() {
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
  }
    // Display all the company in the form select
  renderCompany() {
    return this.props.companies.map((company) => {
      return company.map((c) => {
        return (
          <option value={c.name} key={c.id}>{c.name}</option>
        );
      })
    })
  }

  renderBuilding() {
    let buildingsArray = []
    // Check company field and select buildings
    if (this.state.company === "Toutes les sociétés") {
      this.props.buildings.forEach((building) => {
        building.forEach((b) => {
          buildingsArray.push(b)
        })
      })
    } else if (this.state.company != "Toutes les sociétés") {
      this.props.buildings.forEach((building) => {
        building.forEach((b) => {
          if (b.company_name === this.state.company) {
            buildingsArray.push(b)
          }
        })
      })
    }
    // Display options in dropdown list
    return buildingsArray.map((building) => {
      return (
        <option value={building.name} key={building.id}>{building.name}</option>
      );
    })
  }

  renderTenant() {
    let tenantsArray = []
    // Check selection and select tenants
    // toutes les sociétés AND tous les immeubles
    if (this.state.company === "Toutes les sociétés" && this.state.building === "Tous les immeubles") {
      this.props.tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          tenantsArray.push(t)
        })
      })
    }
    // NOT toutes les sociétés AND tous les immeubles
    else if (this.state.company != "Toutes les sociétés" && this.state.building === "Tous les immeubles") {
      this.props.tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          if (this.state.company === t.company_name) {
            tenantsArray.push(t)
          }
        })
      })
    }
    // toutes les sociétés NOT tous les immeubles
    else if (this.state.company === "Toutes les sociétés" && this.state.building != "Tous les immeubles") {
      this.props.tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          if (this.state.building === t.building_name) {
            tenantsArray.push(t)
          }
        })
      })
    }
    // NOT toutes les sociétés NOT tous les immeubles
    else if (this.state.company != "Toutes les sociétés" && this.state.building != "Tous les immeubles") {
      this.props.tenants.forEach((tenant) => {
        tenant.forEach((t) => {
          if (this.state.company === t.company_name && this.state.building === t.building_name) {
            tenantsArray.push(t)
          }
        })
      })
    }
    // Display options in dropdown list
    return tenantsArray.map((tenant) => {
      return (
        <option value={tenant.name} key={tenant.id}>{tenant.name}</option>
      );
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
              <div className="col-9 col-md-3 pr-0 mt-1">
                <select
                  className="form-control"
                  label="Tenant"
                  name="tenant"
                  type="text"
                  value={this.state.tenant}
                  onChange={this.handleChangeTenant}
                >
                  <option value={"Tous les locataires"} key="01">Tous les locataires</option>
                  {this.renderTenant()}
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
    buildings: state.buildings,
    tenants: state.tenants
  };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ fetchWaters, fetchCompanies, fetchBuildings, fetchTenants, deleteWater }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(WatersIndex);


// const Example = connect(
//   mapStateToProps,
//   mapDispatchToProps,
// )(WatersIndex)

// export default reduxForm({
//   form: 'formWaters' // a unique name for this form
// })(Example)
