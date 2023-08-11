//const fs = require('fs')
//
//const withPlugins = require('next-compose-plugins')
//
//const d3packages = fs.readdirSync('node_modules').filter((name) => name.startsWith('d3-'))
//const withTM = require('next-transpile-modules')(d3packages)


import fs from 'fs';
import withPlugins from 'next-compose-plugins';
const d3packages = fs.readdirSync('node_modules').filter((name) => name.startsWith('d3-'))
import withTM from 'next-transpile-modules';

module.exports = withPlugins([withTM], {
  distDir: 'build',
  images: {
    domains: ['localhost'],
    loader: 'custom',
  },
})
