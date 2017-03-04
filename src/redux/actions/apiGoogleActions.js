import axios from 'axios';
import superagent from 'superagent';
import jsonp from 'jsonp';
import { SET_STORE_PHOTO } from './actionTypes/allActionTypes';

export function setStorePhoto(storePhoto) {
  return {
    type: SET_STORE_PHOTO,
    storePhoto
  };
}

