import React, { Component } from 'react';
import { Link } from 'react-router-dom';
import { connect } from 'react-redux'
import { bindActionCreators } from 'redux';
import { fetchWater } from '../actions/index';

class WatersShow extends Component {

  componentDidMount() {
    if (!this.props.water) {
      this.props.fetchWater(this.props.match.params.id);
    }
  }

  render() {
    if (!this.props.water) {
      return <p>Loading...</p>;
    }

    return (
      <div>
        <div className="post-item">
          <h3>{this.props.water.quantity}</h3>
        </div>
        <Link to="/waters">
          Back
        </Link>
      </div>
    );
  }
}

function mapStateToProps(state, ownProps) {
  const idFromUrl = parseInt(ownProps.match.params.id, 10); // From URL

  const water = state.waters.find(p => p.id === idFromUrl);
    return { water };
  }

function mapDispatchToProps(dispatch) {
  return bindActionCreators({ fetchWater }, dispatch);
}

export default connect(mapStateToProps, mapDispatchToProps)(WatersShow);
