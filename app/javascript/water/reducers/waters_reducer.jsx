import { FETCH_WATERS, FETCH_WATER } from '../actions';

export default function(state = [], action) {
  switch(action.type) {
    case FETCH_WATERS:
      return action.payload;
    case FETCH_WATER:
      return [ action.payload ];
    default:
      return state;
  }
}
