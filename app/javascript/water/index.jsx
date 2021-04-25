import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { createStore, combineReducers, applyMiddleware } from 'redux';
import reduxPromise from 'redux-promise';
import logger from 'redux-logger';
import { BrowserRouter as Router, Route, Switch} from 'react-router-dom';

// import { Router, Route, Switch } from 'react-router-dom';
// import { createHistory as history } from 'history';
 import { createBrowserHistory } from 'history';

import WatersIndex from './containers/waters_index';
// import WatersShow from './containers/waters_show';
import WaterNew from './containers/waters_new';
import WaterEdit from './containers/waters_edit';

// import '../assets/stylesheets/application.scss';
import watersReducer from './reducers/waters_reducer';
import tenantsReducer from './reducers/tenants_reducer';
import companiesReducer from './reducers/companies_reducer';
import buildingsReducer from './reducers/buildings_reducer';
import { reducer as formReducer } from 'redux-form';

const reducers = combineReducers({
  waters: watersReducer,
  tenants: tenantsReducer,
  companies: companiesReducer,
  buildings: buildingsReducer,
  form: formReducer,
});

// let { id } = useParams();
const middlewares = applyMiddleware(reduxPromise, logger);
const water = document.getElementById('water')
const history = createBrowserHistory();

if (water) {
  const initialState = { waters: JSON.parse(water.dataset.posts) };

  // render an instance of the component in the DOM
  ReactDOM.render(
    <Provider store={createStore(reducers, initialState, middlewares)}>
      <Router history={history}>
        <div className="thin-container">
          <Switch>
            <Route path="/waters" exact component={WatersIndex} />
            <Route path="/waters/new" component={WaterNew} />
            <Route path="/waters/edit/:id" component={WaterEdit} />
          </Switch>
        </div>
      </Router>
    </Provider>,
    water
  );
}

            // <Route path="/waters/:id" component={WatersShow} />
