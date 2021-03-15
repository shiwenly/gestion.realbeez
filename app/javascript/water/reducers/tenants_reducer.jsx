import { FETCH_TENANTS } from '../actions';

export default function(state = [], action) {
  switch(action.type) {
    case FETCH_TENANTS:
      return [ action.payload ];
    default:
      return state;
  }
}
