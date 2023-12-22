// ignore_for_file: non_constant_identifier_names

String loginMobileOem = '''
              mutation loginMobileOem (\$input: userCredentials) {
                  loginMobileOem (input: \$input)
              },
          ''';

const String currentUser = r'''
    query currentUser {
      currentUser() {
        _id
        name
        username
        role
        foldersAccessToken
        email
        info   
        access
        userType
        phone
        about
        userCredentialsSent
        isOem
        emailNotification
        organizationName
        organizationType
        chatToken
        chatUUIDMetadata
        chatKeys
        chatUUID
        notificationChannel
        notificationChannelGroupName
      }
    }
  ''';

const String newChatToken = '''
    query getNewChatToken {
      getNewChatToken
    }
  ''';

const String oemStatuses = '''
    query ListOwnOemOpenTickets {
      listOwnOemOpenTickets {
          oem {
              statuses {
                  _id
                  label
                  color
              }
          }
      }
    }
  ''';

String listOwnOemOpenTickets = r"""
          query listOwnOemOpenTickets {
            listOwnOemOpenTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status 
                unread
                isMyTicket
                ticketChatChannels
                createdAt
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                
                }
                machine {
                    _id
                    name
                    serialNumber  
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnOemClosedTickets = r"""
          query listOwnOemClosedTickets {
            listOwnOemClosedTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status
                createdAt
                unread
                isMyTicket
                ticketChatChannels
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name  
                }
                machine {
                    _id
                    name
                    serialNumber 
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnOemUserOpenTickets = r"""
          query listOwnOemUserOpenTickets {
            listOwnOemUserOpenTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status 
                unread
                isMyTicket
                ticketChatChannels
                createdAt
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                
                }
                machine {
                    _id
                    name
                    serialNumber  
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnOemUserClosedTickets = r"""
          query listOwnOemUserClosedTickets {
            listOwnOemUserClosedTickets() {
                _id
                title
                ticketId
                ticketType
                description 
                status 
                unread
                isMyTicket
                ticketChatChannels
                createdAt
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                
                }
                machine {
                    _id
                    name
                    serialNumber  
                }
                assignee {
                  _id
                  name
                }
            }    
          }
   """;

String listOwnCustomerMachines = r"""
          query listOwnCustomerMachines {
            listOwnCustomerMachines() {
                _id
                name
                serialNumber
                description
                documentationFiles
                issues
                image
                thumbnail
                totalOpenTickets
                slug
                customers {
                  _id
                  name
                  oem {
                    _id
                    name
                    logo
                    thumbnail
                    backgroundColor
                    textColor
                    urlOem
                    slug
                    urlOemFacility
                  } 
                }
            }    
          }
   """;

String getOwnOemTicketById = """
          query getOwnOemTicketById (\$id: ID!) {
            getOwnOemTicketById(id: \$id) {
                _id
                title
                ticketId
                description
                notes
                status
                createdAt
                unread
                isMyTicket
                ticketChatChannels
                ticketInternalNotesChatChannels
                procedures {
                  procedure {
                      _id
                      name
                      description
                      state
                      createdAt
                      updatedAt
                      pdfUrl
                  }
               }
                assignee {
                  _id
                  name 
                } 
                facility {
                  _id
                  name
                  urlOemFacility
                  totalMachines
                  totalOpenTickets
                  isQRCodeEnabled
                  generalAccessUrl
                }
                machine {
                    _id
                    name
                    serialNumber
                    description
                    documentationFiles
                    issues
                    image
                    thumbnail
                    totalOpenTickets
                    slug
                }
            }    
          }
   """;

String getOwnCustomerMachineById = """
          query getOwnCustomerMachineById (\$id: ID!) {
            getOwnCustomerMachineById(id: \$id) {
                _id
                name
                serialNumber
                description
                documentationFiles
                issues
                image
                thumbnail
                totalOpenTickets
                slug
                customers {
                  _id
                  name
                  oem {
                    _id
                    name
                    logo
                    thumbnail
                    backgroundColor
                    textColor
                    urlOem
                    slug
                    urlOemFacility
                  } 
                }
                documentTree {
                    _id
                    dataTreeFacilityMobile
                    {
                        _id
                        documents
                    }
                }
            }   
          }
   """;

String createOwnOemTicket = '''
              mutation createOwnOemTicket (\$input: InputCreateOwnOemTicket!) {
                  createOwnOemTicket (input: \$input) {
                     _id
                     title
                     status
                     createdAt
                     unread
                     isMyTicket
                     ticketChatChannels
                     ticketInternalNotesChatChannels
                     description
                     notes
                  }
              },
          ''';

String listOwnOemMachineTicketHistory = """
          query listOwnOemMachineTicketHistoryById (\$id: ID!) {
            listOwnOemMachineTicketHistoryById(id: \$id) {
              _id
                title
                ticketId
                description
                notes
                status
                createdAt
                unread
                isMyTicket
                ticketChatChannels
                ticketInternalNotesChatChannels
                facility {
                  _id
                  name 
                  urlOemFacility
                  totalMachines
                  totalOpenTickets
                  isQRCodeEnabled
                  generalAccessUrl
                }
                machine {
                    _id
                    name
                    serialNumber
                    description
                    documentationFiles
                    issues
                    image
                    thumbnail
                    totalOpenTickets
                    slug
                }
                user {
                    _id
                    name
                    username
                    role
                    email
                    access
                    userType
                    phone
                    about
                    userCredentialsSent
                    isOem
                    emailNotification
                    totalActiveTickets
                    organizationName
                    organizationType
                    chatToken
                    chatUUIDMetadata
                    chatKeys
                    chatUUID
                }
            }
          }
   """;

const String signS3Download = '''
              mutation _signS3Download (\$filename: String!) {
                  _signS3Download (filename: \$filename) {
                      id
                      signedRequest
                      url
                  }
              }
          ''';

// String listOwnOemCustomers = r"""
//           query listOwnOemCustomers {
//             listOwnOemCustomers() {
//               _id
//               name
//               machines {
//                 _id
//                 name
//                 serialNumber
//                 description
//                 customers {
//                     _id
//                     name
//                 }
//               }
//             }
//           }
//    """;
String listAllOwnOemCustomers = r"""
          query ListAllOwnOemCustomers {
    listAllOwnOemCustomers(params: { limit: 100 }) {
        totalCount
        limit
        skip
        currentPage
        customers {
            _id
            name 
            machines {
                _id
                name
                serialNumber
                description 
                customer {
                    _id
                    name 
                }
            }
        }
    }
}

   """;

// String listOwnOemMachines = r"""
//           query listOwnOemMachines {
//             listOwnOemMachines() {
//                   _id
//                   name
//                   serialNumber
//                   description
//                   customers {
//                       _id
//                       name
//                   }
//             }
//           }
//    """;

String listOwnCustomerMachines2 = r"""
          query ListOwnCustomerMachines {
    listOwnCustomerMachines(params: { limit: 100 }) {
        machines {
            _id
            name
            serialNumber
            description
            customer {
                _id
                name
            }
        }
    }
}
   """;

String listOwnOemFacilityUsers = """
          query listOwnOemFacilityUsers(\$facilityId: ID!) {
            listOwnOemFacilityUsers(facilityId: \$facilityId) {
              _id
              name
              username
              role
              email
              info
              access
              userType
              phone 
            }
          }
   """;

String listOwnOemSupportAccounts = r'''
    query listOwnOemSupportAccounts {
      listOwnOemSupportAccounts() {
         _id
        name
        username
        role
        email
        info
        access
        userType
        phone
        about
        userCredentialsSent
      }
    }
  ''';

String updateOwnOemTicket = '''
              mutation updateOwnOemTicket (\$input: InputUpdateOwnOemTicket!) {
                  updateOwnOemTicket (input: \$input) {
                    _id
                    title
                  }
              }
          ''';

String listOwnOemTemplates = r'''
    query listOwnOemTemplates {
       listOwnOemTemplates{
            _id
            templateData
            templateId
            oem {
                _id
                name
            }
        }
    }
  ''';

String listOwnOemSubmissions = r'''
    query listOwnOemSubmissions {
       listOwnOemSubmissions{
            _id
            url
            machine{
                _id
                name
                serialNumber
            }
            inspectionDate
            facility{
                _id
                name
            }
            user{
                _id
            }
            oem{
                _id
            }
            templateId
            templateName
            expired
        }
    }
  ''';

String getOwnOemFormUrlByTemplateId = '''
              query getOwnOemFormUrlByTemplateId (\$input: inputFormMetadata!) {
                  getOwnOemFormUrlByTemplateId (input: \$input)
              },
          ''';

String getOwnOemSubmissionById = '''
              query getOwnOemSubmissionById (\$submissionId: ID!) {
                  getOwnOemSubmissionById (submissionId: \$submissionId)
              }
          ''';

String deleteOwnOemSubmissionById = '''
              mutation deleteOwnOemSubmissionById (\$submissionId: ID!) {
                  deleteOwnOemSubmissionById (submissionId: \$submissionId)
              },
          ''';

String listOwnOemProcedureTemplates = '''
             query ListOwnOemProcedureTemplates {
    listOwnOemProcedureTemplates(params: { limit: 100 }) {
        _id
        name
        description
        createdAt
        updatedAt 
        signatures {
            _id
            signatoryTitle
        }
        children {
            _id
            type
            name
            description
            isRequired
            options {
                _id
                name
            }
            tableOption {
                _id
                rowCount
                columns {
                    _id
                    heading
                    width
                }
            }
            attachments {
                _id
                name
                type
                url
                size
            }
            children {
                _id
                type
                name
                description
                isRequired
                options {
                    _id
                    name
                }
                tableOption {
                    _id
                    rowCount
                    columns {
                        _id
                        heading
                        width
                    }
                }
                attachments {
                    _id
                    name
                    type
                    url
                    size
                }
            }
        }
        pageHeader {
            _id
            name
            type
            url
            size
        }
    }
}
          ''';



String getOwnOemProcedureById = ''' 
              query GetOwnOemProcedureById(\$id: ID!) {
                getOwnOemProcedureById(id: \$id) {
                    _id
                    name
                    description
                    state
                    createdAt
                    updatedAt
                    pdfUrl
                    signatures {
                        _id
                        signatoryTitle
                        name
                        date
                        signatureUrl
                    }
                    children {
                        _id
                        type
                        name
                        description
                        isRequired
                        value
                        options {
                            _id
                            name
                        }
                        tableOption {
                            _id
                            rowCount
                            columns {
                                _id
                                heading
                                width
                            }
                        }
                        attachments {
                            _id
                            name
                            type
                            url
                            size
                        }
                        children {
                            _id
                            type
                            name
                            description
                            isRequired
                            value
                            options {
                                _id
                                name
                            }
                            tableOption {
                                _id
                                rowCount
                                columns {
                                    _id
                                    heading
                                    width
                                }
                            }
                            attachments {
                                _id
                                name
                                type
                                url
                                size
                            }
                        }
                    }
                    pageHeader {
                        _id
                        name
                        type
                        url
                        size
                    }
                }
             }

          ''';

String ATTACH_PROCEDURE_TO_WORK_ORDER = ''' 
            mutation AttachOwnOemProcedureToWorkOrder(\$input: InputAttachProcedureToWorkOrder!) {
    attachOwnOemProcedureToWorkOrder(input: \$input)
}
 
          ''';
