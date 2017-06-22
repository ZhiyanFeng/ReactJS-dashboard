import React from 'react';
import { Link } from 'react-router';
import { Button, Glyphicon } from 'react-bootstrap';
import { connect  } from 'react-redux';

class EditableCell extends React.Component{
    constructor(props) {
        super(props);
        this.handleEditCell = this.handleEditCell.bind(this);
        this.handleKeyDown = this.handleKeyDown.bind(this);
        this.handleChange = this.handleChange.bind(this);
        this.getValue = this.getValue.bind(this);
        this.state = { /* initial state */  
            isEditMode: false,
            ref: "",
            data: ""
        };
    }

    componentWillMount() {
        this.setState({
            ref: this.props.field,
            data: this.props.data,
            originalData: this.props.data
        });
    }

    handleEditCell(evt) {
        this.setState({isEditMode: true});
    }

    handleKeyDown(evt) {
        switch (evt.keyCode) {
            case 13: // Enter
                this.setState({isEditMode: false});
                break;

        }

    }
    handleChange(evt) {
        this.setState({data: evt.target.value});

    }

    getValue() {
        return this.state.data;
    }

    setDefault() {
        this.setState({isEditMode: false});
    }

    render() {
        var cellHtml;
        if (this.state.isEditMode) {
            cellHtml = <input type='text' value={this.state.data} onKeyDown={this.handleKeyDown} onChange={this.handleChange} />
        }
        else {
            cellHtml = <div onClick={this.handleEditCell}>{this.state.data}</div>

        }
        return (
            <td>{cellHtml}</td>
        );
    }
};

export default EditableCell;
