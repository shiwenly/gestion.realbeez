import { FETCH_BUILDINGS } from '../actions';

export default function(state = [], action) {
  switch(action.type) {
    case FETCH_BUILDINGS:
      return [ action.payload ];
    default:
      return state;
  }
}
