module.exports = {
  site: {
    title: 'My Knowledge Base',
    theme: 'default',
    theme_dir: __dirname + '/themes',
    content_dir: '/var/www/raneto/content',
    port: 3000,
    host: '0.0.0.0',
    show_on_home_default: true,
    searchExtraLanguages: ['es', 'fr', 'de'],
    locale: 'en',
    authentication: {
      enabled: false,
      token_secret: 'CHANGE_THIS_TO_SOMETHING_RANDOM',
      allow_username_signup: true,
      allow_editing: true,
      allow_deleting: true
    },
    log: {
      level: 'info',
      format: 'combined',
      file: 'access.log'
    }
  }
};
