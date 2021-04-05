const ROOT_URL = '../api/v1/waters';
const TENANT_URL = '/api/v1/tenants'

export const FETCH_WATERS = 'FETCH_WATERS';
export const FETCH_WATER = 'FETCH_WATER';
export const WATER_CREATED = 'WATER_CREATED';
export const FETCH_TENANTS = 'FETCH_TENANTS';


export function fetchTenants() {
  const promise = fetch(`${TENANT_URL}`)
    .then(response => response.json());

  return {
    type: FETCH_TENANTS,
    payload: promise
  };
}

export function fetchWaters() {
  const promise = fetch(`${ROOT_URL}`)
    .then(response => response.json());

  return {
    type: FETCH_WATERS,
    payload: promise
  };
}

export function fetchWater(id) {
  const promise = fetch(`${ROOT_URL}/${id}`)
  .then(response => response.json());

  return {
    type: FETCH_WATER,
    payload: promise
  };
}

export function createWater(body, callback) {
  const request = fetch(ROOT_URL, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    credentials: 'same-origin',
    body: JSON.stringify(body)
  }).then(response => response.json())
    .then(callback);
  return {
    type: WATER_CREATED,
    payload: request
  };
}
