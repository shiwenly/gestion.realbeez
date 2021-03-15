import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux';
import { fetchWaters } from '../actions/index';

class WatersIndex extends Component {
  componentDidMount() {
    this.props.fetchWaters();
  }

  renderWaters() {
    return this.props.waters.map((water) => {
      return (
        <Link to={`/waters/${water.id}`} key={water.id}>
          <div className="post-item">
            <h3>{water.quantity}</h3>
          </div>
        </Link>
      );
    });
  }

  render() {
    return (
      <div>
        <div className="first-row">
          <h3>Consommation d'eau</h3>
          <Link className="btn btn-primary btn-cta" to="/waters/new">
           Déclarer ma conso!
          </Link>
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

