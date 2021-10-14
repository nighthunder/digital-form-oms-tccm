import React, { useState } from 'react';
import { useHistory } from "react-router-dom";
import { useLocation } from "react-router-dom";
import './styles.css';
import { TextField, Button, InputLabel, Select, MenuItem, CircularProgress } from '@material-ui/core';
import { AES, mode } from 'crypto-js';

import api from '../../services/api';

import { connect } from 'react-redux';

const styles = {
    TextField: {
      marginTop: 0
    },
    Button: {
      margin: 24,
      marginBottom: 0
    }
};

function Cadastro({user}) {

    const location = useLocation();
    console.log(user)

    const [form, setForm] = useState({
        adminId: user[location.state.hospitalIndex].userid,
        adminGroupRoleid: user[location.state.hospitalIndex].grouproleid,
        hospitalUnitId: location.state.hospitalId,
        nome: '',
        sobrenome: '',
        crm: '',
        funcao: '',
        email: '',
        telefone: '',
        senha: '',
        confirmasenha: '',
        error: ''
    })

    const [loading, setLoading] = useState(false);

    const history = useHistory();

    function validators() {
        if(form.email !== '' && (!form.email.includes('@') || !form.email.includes('.com'))) {
            return 'Email Inválido';
        }
        
        if(form.senha !== '' && form.confirmasenha !== '' && form.senha !== form.confirmasenha) {
            return 'As senhas não coincidem';
        }

        return '';
    }

    function handleChange(e) {
        const target = e.target;
        let value = target.value;
        const name = target.name;

        if(name == 'senha' || name == 'confirmasenha') {
            const encryptedPassword = AES.encrypt(value, 10, { mode: mode.ECB }).toString();
            value = encryptedPassword
        }

        setForm({
            ...form,
            [name]: value,
        });

        console.log(form);
    }

    async function handleRegister(e) {
        e.preventDefault();

        setLoading(true);
        try {
            const response = await api.post('/register', form);
            console.log(response);
            history.replace('/hospital');
        } catch(e) {
            setLoading(false);
            console.log(e)
            setForm({
                ...form,
                error: 'Não foi possível realizar o cadastro.'
            })
        }
        let validateErrors = validators();
        setForm({
            ...form,
            error: validateErrors
        });
        console.log(form, validateErrors)
        setLoading(false);
        history.go(-1)
    }

    return (
        <main className="container cadastro">
            <h2>Cadastro de novos usuários</h2>
            <form noValidate autoComplete="off" onSubmit={handleRegister}>

                <div className="form-inputs">
                    <TextField style={styles.TextField} name="nome" label="Nome" type="text" onChange={handleChange} />
                    <TextField style={styles.TextField} name="sobrenome" label="Sobrenome" type="text" onChange={handleChange} />
                    <TextField style={styles.TextField} name="crm" label="CRM" type="text" onChange={handleChange} />
                    <div>
                        <InputLabel>Função</InputLabel>
                        <Select name="funcao" label="Funcao" value={form.funcao} onChange={handleChange}>
                            <MenuItem value="Administrador">Administrador</MenuItem>
                            <MenuItem value="ETL - Arquivos">ETL - Arquivos</MenuItem>
                            <MenuItem value="ETL - BD a BD">ETL - BD a BD</MenuItem>
                            <MenuItem value="Gestor de Ontologia">Gestor de Ontologia</MenuItem>
                            <MenuItem value="Gestor de Repositório">Gestor de Repositório</MenuItem>
                            <MenuItem value="Notificador Médico">Notificador Médico</MenuItem>
                            <MenuItem value="Notificador Profissional de Saúde">Notificador Profissional de Saúde</MenuItem>
                        </Select>
                    </div> 
                    <TextField style={styles.TextField} name="email" label="Email" type="email" onChange={handleChange} />
                    <TextField style={styles.TextField} name="telefone" label="Telefone" type="text" onChange={handleChange} />
                    <TextField style={styles.TextField} name="senha" label="Senha" type="password" onChange={handleChange} />
                    <TextField style={styles.TextField} name="confirmasenha" label="Confirme a senha" type="password" onChange={handleChange} />
                </div>

                <div className="register-form">
                    <span className="error">{ form.error }</span>
                    <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={
                        form.nome === '' || form.sobrenome === '' || form.email === '' || form.telefone === '' || form.senha === '' || form.confirmasenha === '' ||
                        form.crm === '' || form.funcao === ''
                    }>
                        { !loading &&
                            'Registrar'
                        }
                        { loading &&
                            <CircularProgress color="white"/>
                        }                    
                    </Button>
                </div>
                
            </form>
        </main>
    );
}

export default connect(state => ({ user: state.user }))(Cadastro);