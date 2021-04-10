const ROOT_URL = '../api/v1/waters';
const TENANT_URL = '/api/v1/tenants'
const COMPANY_URL = '/api/v1/companies'
const BUILDING_URL = '/api/v1/buildings'

export const FETCH_WATERS = 'FETCH_WATERS';
export const FETCH_WATER = 'FETCH_WATER';
export const WATER_CREATED = 'WATER_CREATED';
export const FETCH_TENANTS = 'FETCH_TENANTS';
export const FETCH_COMPANIES = 'FETCH_COMPANIES';
export const FETCH_BUILDINGS = 'FETCH_BUILDINGS';

export function fetchBuildings() {
  const promise = fetch(`${BUILDING_URL}`)
    .then(response => response.json());
  return {
    type: FETCH_BUILDINGS,
    payload: promise
  };
}

export function fetchCompanies() {
  const promise = fetch(`${COMPANY_URL}`)
    .then(response => response.json());
  return {
    type: FETCH_COMPANIES,
    payload: promise
  };
}

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
