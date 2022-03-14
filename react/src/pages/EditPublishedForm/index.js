// View do formulário quando é preenchido.
import React, { useState, useEffect } from 'react';
import './styles.css';
import { useLocation } from "react-router-dom";
import { Scrollchor } from 'react-scrollchor';
import { TextField, Button, InputLabel, Select } from '@material-ui/core';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import ArrowUpwardIcon from '@mui/icons-material/ArrowUpwardRounded';
import Edit from '@mui/icons-material/Edit';
import QuestionMark from '@mui/icons-material/QuestionMark';
import { makeStyles } from '@material-ui/styles';
import api from '../../services/api';
import { connect } from 'react-redux';
import { useHistory } from "react-router-dom";
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';


const useStyles = makeStyles({
    root: {
      '& input': {
          fontSize: '0.75rem',
      }
    },
});

function EditPublishedForm({logged, user, participantId}) {

    const location = useLocation();  
    const classes = useStyles();
    //console.log("Location Formulario", location);
    const titles = ['Admissão','Acompanhamento','Desfecho']
    const [form, setForm] = useState({}); // descrições das perguntas
    const [questionsgroups, setQuestionsGroups] = useState({}); // descrições dos grupos
    const [formError, setFormError] = useState('')
    const history = useHistory();
    const [questions, setQuestions] = useState([]);
    const [questionstype, setQuestionsType] = useState([]);
    const [loadedResponses, setLoadedResponses] = useState(false);
    const [hospitalName, setHospitalName] = useState('');

    // popup
    const [popupTitle, setPopupTitle] = useState('');
    const [popupBodyText, setPopupBodyText] = useState([]);

    useEffect(() => {
        async function loadForm() {
            const response = await api.get('/form/' + location.state.modulo);
            setQuestions(response.data);

            //console.log("QUESTOES", questions);
            //console.log("formRecordId", location.state.formRecordId);
        }
        loadForm();
        setHospitalName(user[location.state.hospitalIndex].hospitalName);

        async function loadQuestionTypeAltText() {
            const response = await api.get('/questiontype/' + location.state.modulo);
            setQuestionsType(response.data);    

        }
        //loadQuestionTypeAltText();
    }, [])

    function handleChange(e) {
        const target = e.target;
        const value = target.value;
        const name = target.name;
        //console.log('idQuestão: ' + target.name, 'value: ' + target.value);
        setForm({
            ...form,
            [name]: value,
        });
        console.log("form", form);
    }
    
    function handleChangeGroups(e) {
        const target = e.target;
        const value = target.value;
        const name = target.name;
        //console.log('idQuestão: ' + target.name, 'value: ' + target.value);
        setQuestionsGroups({
            ...questionsgroups,
            [name]: value,
        });
        console.log("questions groups", questionsgroups);
    }

    function checkTitle(index, question) { // tratamento da repetição dos nomes dos grupos
        if(index-1 < 0) {
            return true;
        }
        if(typeof(questions[index - 1].dsc_qst_grp) == 'string') {
            if(question.dsc_qst_grp !== questions[index - 1].dsc_qst_grp) {
                return true;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    // popup
    const [open, setOpen] = React.useState(false);
    const handleClickOpen = (question) => {
        setOpen(false);
        setPopupTitle("Informações sobre a questão");
        setPopupBodyText(question.qst_type+" : "+question.qst_type_comment);
        setOpen(true);
    };
    const handleInfo = () => {
        setOpen(false);
        setPopupTitle("[Atenção] Informações sobre a edição");
        setPopupBodyText("Neste modo de edição só é possível reodernar questões e agrupamentos ou alterar suas descrições. Para ser possível fazer mais alterações é necessário criar uma pesquisa derivada.");
        setOpen(true);
    };
    const handleAddSurvey = () => {
        history.push('/add-survey');
    };
    const handleAddBasedSurvey = () => {
        history.push('/add-based-survey');
    };
    const handleClose = () => {
        setOpen(false);
    };


    async function submit(e) {
        setFormError("");
        e.preventDefault();
        console.log(form);

        let request;
        let response;
        let param;

        console.log('ATUALIZAÇÃO DO FORM ', location.state.formRecordId);

        request = {
            questionsdescriptions: JSON.stringify(form),  
            modulo: location.state.modulo
        }

        //console.log( [ request.info['userid'], request.info['grouproleid'], request.info['hospitalunitid'], request.modulo, request.questionsdescriptions ]);

        response = await api.put('/formquestionsdesc/' + location.state.modulo, request);

        let errors;
        setFormError(response.data[0].msgRetorno);

        request = {
            questionsgroups: JSON.stringify(questionsgroups),  
            modulo: location.state.modulo
        }

        response = await api.put('/formgroupsdesc/' + location.state.modulo, request);
        setFormError(response.data[0].msgRetorno);
    }

    function handleBackButton(){
        history.goBack();
    }

    return (
        <main className="container">
            <div>
                <div className="mainNav">
				    <h2 className="pageTitle">Módulo { location.state.modulo } - { titles[location.state.modulo-1] } - {location.state.moduleStatus} [Edição]</h2>
                    <ArrowBackIcon className="ArrowBack" onClick={handleBackButton}/>
                    <Scrollchor to="#vodan_br"><ArrowUpwardIcon className="ArrowUp" /></Scrollchor>
                </div>
                 <h1 className="questionnaireDesc"> Questionário: {location.state.questionnaireDesc} ( {location.state.questionnaireVers} ) {location.state.questionnaireStatus}  </h1>
                <form className="module" onSubmit={submit}>
                    <div>
                    { questions.length === 0 && (location.state.formRecordId ? !loadedResponses : true) &&
                        <div className="loading">
                            <img src="assets/loading.svg" alt="Carregando"/>
                        </div>
                    }
                    {
                        console.log("QUESTIONS2", questions)
                    }
                    {questions.map((question, index) => (
                        <div className="qst qst2" key={question.qstId}>
                            {/* Se for um novo grupo de questões*/}
                            { (question.dsc_qst_grp !== ""  && checkTitle(index, question)) &&
                            <div className="groupHeader" id={question.qstId}>
                               <TextField className="inputQst" name={String(question.qstGroupId)} value={questionsgroups[question.qstGroupId] ? questionsgroups[question.qstGroupId] : question.dsc_qst_grp } onChange={handleChangeGroups}>{question.dsc_qst_grp}</TextField>
                                <Edit className="ediIcon" onClick={handleInfo}></Edit><QuestionMark className="qstIcon" ></QuestionMark>
                                <p className="questionType groupType">Grupo de questões</p>
                            </div>
                            }
                            <div className="qstBody">
                            
                            {/* Se for do tipo Date question*/}
                            { (question.qst_type === "Date question") && 
                            <div>
                                <InputLabel className="qstLabel">Questão</InputLabel><Edit className="ediIcon" onClick={handleInfo}></Edit><QuestionMark className="qstIcon" onClick={() => handleClickOpen(question)}></QuestionMark>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                <TextField className={classes.root} className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                                { question.sub_qst !== '' &&
                                 <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                }
                            </div>
                            }

                            {/* Se for do tipo Number question*/}
                            { (question.qst_type === "Number question") && 
                            <div>
                            {/*<TextField  type="number" name={String(question.qstId)} label={question.dsc_qst} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } />*/}
                            <InputLabel>Questão:</InputLabel><Edit className="ediIcon" onClick={handleInfo}></Edit><QuestionMark className="qstIcon" onClick={ ( ) => handleClickOpen(question) }></QuestionMark>
                            <p className="questionType">Tipo da questão: {question.qst_type}</p>
                            <TextField className="inputQst inputQst2"  name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } onChange={handleChange} fullWidth multiline>{question.dsc_qst}</TextField>
                            { question.sub_qst !== '' &&
                               <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                            }
                            </div>
                            }

                            {/* Se for do tipo List question ou YNU_Question ou YNUN_Question e tenha menos de 6 opções */}
                            { (question.qst_type === "List question" || question.qst_type === "YNU_Question" || question.qst_type === "YNUN_Question") && ( (question.rsp_pad.split(',')).length < 6 ) &&
                            <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                <InputLabel>Questão:</InputLabel><Edit className="ediIcon" onClick={handleInfo}></Edit><QuestionMark className="qstIcon" onClick={ ( ) => handleClickOpen(question) }></QuestionMark>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                <TextField  className="inputQst inputQst2" onChange={handleChange} name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst }  fullWidth multiline>{question.dsc_qst}</TextField>
                                <p className="subQstDesc">Respostas padronizadas</p>
                                <Select multiple native label={question.dsc_qst} aria-label={question.dsc_qst} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : '' }>
                                        {question.rsp_pad.split(',').map((item) => (
                                            <option key={item} value={item}>{ item }</option>
                                        ))}
                                </Select>
                                { question.sub_qst !== '' &&
                                 <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                }
                            </div>
                            } 

                            {/* Se for do tipo List question ou YNU_Question ou YNUN_Question e tenha 6 ou mais opções */}
                            { (question.qst_type === "List question" || question.qst_type === "YNU_Question" || question.qst_type === "YNUN_Question") && ( (question.rsp_pad.split(',')).length >= 6 ) &&
                            <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                <InputLabel>Questão:</InputLabel><Edit className="ediIcon" onClick={handleInfo}></Edit><QuestionMark className="qstIcon" onClick={ ( ) => handleClickOpen(question) }></QuestionMark>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                <TextField  className="inputQst inputQst2" onChange={handleChange} name={String(question.qstId)} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst }  fullWidth multiline>{question.dsc_qst}</TextField>
                                <p className="subQstDesc">Respostas padronizadas</p>
                                <Select multiple native label={question.dsc_qst} label={question.dsc_qst} aria-label={question.dsc_qst} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : '' }>
                                        {question.rsp_pad.split(',').map((item) => (
                                            <option key={item} value={item}>{ item }</option>
                                        ))}
                                </Select>
                                { question.sub_qst !== '' &&
                                 <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                }
                            </div>
                            } 

                            {/* Se for do tipo Text_Question ou Laboratory question ou Ventilation question*/}
                            { (question.qst_type === "Text_Question" || question.qst_type === "Laboratory question" || question.qst_type === "Ventilation question") && 
                            <div>
                            <InputLabel>Questão:</InputLabel><Edit className="ediIcon" onClick={handleInfo}></Edit><QuestionMark className="qstIcon" onClick={ ( ) => handleClickOpen(question) }></QuestionMark>
                            <p className="questionType">Tipo da questão: {question.qst_type}</p>
                            <TextField  className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                            { question.sub_qst !== '' &&
                               <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                            }
                            </div>
                            }

                            {/* Se for do tipo Boolean_Question*/}
                            { (question.qst_type === "Boolean_Question") && 
                            <div className="MuiTextField-root  MuiTextField-root2 MuiForm">
                                <InputLabel>Questão:</InputLabel><Edit className="ediIcon" onClick={handleInfo}></Edit><QuestionMark className="qstIcon" onClick={ ( ) => handleClickOpen(question) }></QuestionMark>
                                <p className="questionType">Tipo da questão: {question.qst_type}</p>
                                <TextField  className="inputQst inputQst2" name={String(question.qstId)} onChange={handleChange} value={form[question.qstId] ? form[question.qstId] : question.dsc_qst } fullWidth multiline>{question.dsc_qst}</TextField>
                                <p className="subQstDesc">Respostas padronizadas</p>
                                <Select multiple native label={question.dsc_qst} aria-label={question.dsc_qst} onChange={handleChange}>
                                       <option label='Sim'/>
                                       <option label='Não'/>
                                </Select>
                                { question.sub_qst !== '' &&
                                  <p className="subQstInfo"> É um subquestão de {question.sub_qst} que aparece quando a opção Sim é selecionada.</p>      
                                }
                            </div>
                            } 
                            </div>    
                        </div>
                    ))}
                    </div>
                    <div className="form-submit">
                        <p className="error"> 
                            { formError} 
                        </p>
                        <Button variant="contained" type="submit" color="primary">Salvar</Button>
                    </div>
                </form>
                <Dialog key={Math.random()}
                            open={open}
                            onClose={handleClose}
                            aria-labelledby="alert-dialog-title"
                            aria-describedby="alert-dialog-description"
                            >
                            <DialogTitle id="alert-dialog-title">
                                {popupTitle}
                            </DialogTitle>
                            <DialogContent>
                                <DialogContentText id="alert-dialog-description">
                                {popupBodyText} 
                                </DialogContentText>
                            </DialogContent>
                            <DialogActions>
                                <Button onClick={handleClose}>Fechar [x]</Button>
                            </DialogActions>
                </Dialog>
                <aside> 
                    <p className="sidebarTitle">Menu de navegação</p>
                    {questions.map((question, index) => (
                        (question.dsc_qst_grp !== ""  && checkTitle(index, question)) && 
                            <Scrollchor className="scrollchorlink" to={'#' + question.qstId} >
                                <div className="anchorLink" arial-label={question.dsc_qst_grp}>{question.dsc_qst_grp}</div>
                            </Scrollchor>
                    ))}    
                </aside>
                
            </div>
        </main>
    );
}
export default connect(state => ({ logged: state.logged, user:state.user, participantId: state.participantId }))(EditPublishedForm);