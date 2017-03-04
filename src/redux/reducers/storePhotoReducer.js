const storePhotoReducer = (state = {
    storePhoto: ""
}, action) => {
  switch(action.type) {
    case "SET_STORE_PHOTO":
          state ={
              storePhoto: action.storePhoto
          };
          break;
  }
    return state;
}

module.exports = {
    storePhotoReducer,
}

