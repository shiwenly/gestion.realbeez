import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { createStore, combineReducers, applyMiddleware } from 'redux';
import reduxPromise from 'redux-promise';
import logger from 'redux-logger';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { createHistory as history } from 'history';

import WatersIndex from './containers/waters_index';
import WatersShow from './containers/waters_show';
import WatersNew from './containers/waters_new';

// import '../assets/stylesheets/application.scss';
import watersReducer from './reducers/waters_reducer';
import tenantsReducer from './reducers/tenants_reducer';
import { reducer as formReducer } from 'redux-form';

const reducers = combineReducers({
  waters: watersReducer,
  tenants: tenantsReducer,
  form: formReducer,
});

const middlewares = applyMiddleware(reduxPromise, logger);
const water = document.getElementById('water')

if (water) {
  const initialState = { waters: JSON.parse(water.dataset.posts) };

  // render an instance of the component in the DOM
  ReactDOM.render(
    <Provider store={createStore(reducers, initialState, middlewares)}>
      <Router history={history}>
        <div className="thin-container">
          <Switch>
            <Route path="/waters" exact component={WatersIndex} />
            <Route path="/waters/new" component={WatersNew} />
            <Route path="/waters/:id" component={WatersShow} />
          </Switch>
        </div>
      </Router>
    </Provider>,
    water
  );
}

