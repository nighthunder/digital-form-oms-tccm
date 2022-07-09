import React from 'react';
import './styles.css';
import { TextField } from '@material-ui/core';

class NewInput extends React.Component {
    constructor(props) {
      super(props);
      this.state = {value: ''};
  
      this.handleChange = this.handleChange.bind(this);
    }
  
    handleChange(event) {
      this.setState({value: event.target.value});
    }
  
    render() {
      return (
        <TextField 
            fullWidth 
            id={this.props.id} 
            label={this.props.descriptionInput} 
            variant="outlined" 
            size="small"
            value={this.state.value}
            onChange={this.handleChange}
            required="required"
        />
      );
    }
  }

export default NewInput