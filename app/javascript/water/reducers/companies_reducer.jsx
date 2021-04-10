import { FETCH_COMPANIES } from '../actions';

export default function(state = [], action) {
  switch(action.type) {
    case FETCH_COMPANIES:
      return [ action.payload ];
    default:
      return state;
  }
}
