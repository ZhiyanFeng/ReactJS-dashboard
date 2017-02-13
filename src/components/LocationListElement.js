import React from 'react';
import { Link } from 'react-router';
import {Button, Glyphicon} from 'react-bootstrap';
import { connect  } from 'react-redux';

class LocationListElement extends React.Component{
    constructor(props){
        super(props);
        this.modalDeleteShow = this.modalDeleteShow.bind(this);
    }

    modalDeleteShow(event){
        const locationId = Number(event.target.dataset.id);
        const phoneNumber = event.target.dataset.phone_number;
        this.props.dispatch({
            type: 'location.modalDelete',
            id: locationId,
            phone: phoneNumber,  
        })

    }
    
    render()
    {
        const location = this.props.location;
        return (
            <tr> 
                <td>{location.id}</td>
                <td>{location.formatted_address}</td>
                <td>{location.city}</td>
                <td>{location.location_name}</td>
                <td>{location.member_count}</td>
                <td>
                    <Link to={'/ltr/location/edit/' + location.id}>
                        <Button type="button" className="btn btn-primary" bsSize="small">Edit <Glyphicon glyph="edit"/></Button>
                    </Link>
                </td>
                <td>
                    <Button type="button" className="btn btn-danger" bsSize="small" data-id={location.id} data-phone_number={location.phone_number} onClick={this.modalDeleteShow}>Delete <Glyphicon glyph="remove-circle"/></Button>
                </td>
            </tr>
        );
    }
}

export default connect()(LocationListElement);
