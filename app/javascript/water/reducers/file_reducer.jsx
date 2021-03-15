import { FILE_UPLOAD } from '../actions';

export default function(state = [], action) {
  switch(action.type) {
    case FILE_UPLOAD:
      return [ action.payload ];
    default:
      return state;
  }
}
