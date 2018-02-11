var mongoose = require('mongoose');
var bcrypt = require('bcrypt-nodejs');

var UserSchema = mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    firstName: {
        type: String,
        trim: true
    },
    lastName: {
        type:String,
        trim: true
    },
    password: {
        type: String,
        required: true,
        trim: true
    }
});

UserSchema.statics.comparePasswords = function(password, matchedPassword) {
    // Should change to async
    return bcrypt.compareSync(password, matchedPassword);
};

UserSchema.statics.hashPassword = function(password, callback) {
    bcrypt.genSalt(10, function(error, salt) {
        if (error) {
            return callback(error);
        }
        bcrypt.hash(password, salt, null, function(error, hashedPassword) {
            return callback(error, hashedPassword);
        });
    });
};

UserSchema.statics.passwordConfirm = function(password, confirmPassword) {
    return password === confirmPassword;
};

/*
 * Default authentication check. If no session exists, redirect to sign in page.
 */
UserSchema.statics.isAuthenticated = function(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
    }
    res.redirect('/sign-in');
};

UserSchema.pre('save', function(next) {
    var user = this;
    UserSchema.statics.hashPassword(user.password, function(error, hashedPassword) {
        if (error) {
            next(error);
        }
        user.password = hashedPassword;
        next();
    });
});

var User = mongoose.model('User', UserSchema);
module.exports = User;