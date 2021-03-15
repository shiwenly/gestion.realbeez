import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux';
import { fetchWaters } from '../actions/index';

class WatersIndex extends Component {
  componentDidMount() {
    this.props.fetchWaters();
  }

  // <Link to={`/waters/${water.id}`} key={water.id}>
  //   <div className="post-item">
  //     <h3>{water.quantity}</h3>
  //   </div>
  // </Link>

  renderTableData() {
    return this.props.waters.map((water, index) => {
       const { id, submission_date, quantity, tenant_name, building_name, company_name, photo } = water //destructuring
       return (
          <tr key={id}>
             <td>{submission_date}</td>
             <td>{company_name}</td>
             <td>{building_name}</td>
             <td>{tenant_name}</td>
             <td>{quantity}</td>
          </tr>
       )
    })
   }

   renderTableHeader() {
       let header = ['Date', "Société", "Immeuble", "Locataire", "Consommation"]
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

  render() {
    return (
      <div style={{fontSize: '12px' }}>
      <h3 className="text-center mt-5 mb-5" style={{color: '#D8A727', fontFamily: 'Simply Rounded', letterSpacing: '1px'}}>Consommation d'eau</h3>
        <div className="first-row">
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
  return { waters: state.waters };
}

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ fetchWaters }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(WatersIndex);

