//
//  ETPTokenView.swift
//  EmailTokenPicker
//
//  Created by Dmitry Shlyugaev on 07/05/2017.
//
//


import UIKit

@objc public enum ETPTokenViewStyle: Int {
    case rounded
    case squared
}

@objc public enum ETPTokenViewScrollDirection: Int {
    case vertical
    case horizontal
}

//MARK: - ETPTokenViewDelegate

@objc public protocol ETPTokenViewDelegate {
    
    /**
     Asks the delegate whether the token should be added
     
     - parameter tokenView: ETPTokenView object
     - parameter token:     ETPToken object that needs to be added
     
     - returns: Boolean
     
     */
    @objc optional func tokenView(_ tokenView: ETPTokenView, shouldAddToken token: ETPToken) -> Bool
    @objc optional func tokenView(_ tokenView: ETPTokenView, willAddToken token: ETPToken)
    @objc optional func tokenView(_ tokenView: ETPTokenView, shouldChangeAppearanceForToken token: ETPToken) -> ETPToken?
    @objc optional func tokenView(_ tokenView: ETPTokenView, didAddToken token: ETPToken)
    @objc optional func tokenView(_ tokenView: ETPTokenView, didFailToAdd token: ETPToken)
    
    @objc optional func tokenView(_ tokenView: ETPTokenView, shouldDeleteToken token: ETPToken) -> Bool
    @objc optional func tokenView(_ tokenView: ETPTokenView, willDeleteToken token: ETPToken)
    @objc optional func tokenView(_ tokenView: ETPTokenView, didDeleteToken token: ETPToken)
    @objc optional func tokenView(_ tokenView: ETPTokenView, didFailToDeleteToken token: ETPToken)
    
    @objc optional func tokenView(_ tokenView: ETPTokenView, willChangeFrameWithX: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
    @objc optional func tokenView(_ tokenView: ETPTokenView, didChangeFrameWithX: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)
    
    @objc optional func tokenView(_ tokenView: ETPTokenView, didSelectToken token: ETPToken)
    @objc optional func tokenViewDidBeginEditing(_ tokenView: ETPTokenView)
    @objc optional func tokenViewDidEndEditing(_ tokenView: ETPTokenView)
    
    func tokenView(_ token: ETPTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?)
    func tokenView(_ token: ETPTokenView, displayTitleForObject object: AnyObject) -> String
    @objc optional func tokenView(_ token: ETPTokenView, displayDetailForObject object: AnyObject) -> String
    @objc optional func tokenView(_ token: ETPTokenView, titleForToken object: AnyObject) -> String
    @objc optional func tokenView(_ token: ETPTokenView, didSelectRowAtIndexPath indexPath: IndexPath)
    
    @objc optional func tokenViewShouldDeleteAllToken(_ tokenView: ETPTokenView) -> Bool
    @objc optional func tokenViewWillDeleteAllToken(_ tokenView: ETPTokenView)
    @objc optional func tokenViewDidDeleteAllToken(_ tokenView: ETPTokenView)
    @objc optional func tokenViewDidFailToDeleteAllTokens(_ tokenView: ETPTokenView)
    
    @objc optional func tokenViewDidShowSearchResults(_ tokenView: ETPTokenView)
    @objc optional func tokenViewDidHideSearchResults(_ tokenView: ETPTokenView)
}

//MARK: - ETPTokenView

open class ETPTokenView: UIView {
    
    //MARK: - Private Properties
    
    var _tokenField: ETPTokenField!
    fileprivate var _searchTableView: UITableView = UITableView(frame: .zero, style: UITableViewStyle.plain)
    fileprivate var _resultArray = [AnyObject]()
    fileprivate var _showingSearchResult = false
    fileprivate var _indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    fileprivate var _lastSearchString: String = ""
    fileprivate var _intrinsicContentHeight: CGFloat = UIViewNoIntrinsicMetric
    
    //MARK: - Public Properties
    
    //returns the value of field
    open var text : String {
        get {
            return _tokenField.text!.substring(with: _tokenField.text!.characters.index(_tokenField.text!.startIndex, offsetBy: 1)..<self._tokenField.text!.endIndex)
        }
        set (string) {
            _tokenField.text = ETPTextEmpty+string
        }
    }
    
    //default is true. token can be deleted with keyboard 'x' button
    open var shouldDeleteTokenOnBackspace = true
    
    //default is true. If enabled - textfield will hide tokens on end editing
    open var shouldUntokenizeOnEndEditing = true
    
    //Only works for iPhone now, not iPad devices. default is false. If true, search results are hidden when one of them is selected
    open var shouldHideSearchResultsOnSelect = false
    
    //default is false. If true, already added token still appears in search results
    open var shouldDisplayAlreadyTokenized = false
    
    //default is true. Sorts the search results alphabatically according to title provided by tokenView(_:displayTitleForObject) delegate
    open var shouldSortResultsAlphabatically = true
    
    //default is true. If false, token can only be added from picking search results. All the text input would be ignored
    open var shouldAddTokenFromTextInput = true
    
    //default is 1. If set to 0, it shows all search results without typing anything
    open var minimumCharactersToSearch = 1
    
    open var searchResultHeight:CGFloat = 200.0
    
    //default is nil
    weak open var delegate: ETPTokenViewDelegate?
    
    open var tokenBackgroundColor: UIColor = UIColor.blue
    
    //default is .Vertical.
    open var direction: ETPTokenViewScrollDirection = .vertical {
        didSet {
            _updateTokenField()
        }
    }
    
    //default is whiteColor
    override open var backgroundColor: UIColor? {
        didSet {
            if (_tokenField != nil) {
                _tokenField.backgroundColor = .clear
            }
        }
    }
    
    //default is (TokenViewWidth, 200)
    open var searchResultSize: CGSize = CGSize.zero {
        didSet {
            _searchTableView.frame.size = searchResultSize
        }
    }
    
    //default is whiteColor()
    open var searchResultBackgroundColor: UIColor = UIColor.white {
        didSet {
            _searchTableView.backgroundColor = searchResultBackgroundColor
        }
    }
    
    //default is UIColor.blueColor()
    open var activityIndicatorColor: UIColor = UIColor.blue {
        didSet {
            _indicator.color = activityIndicatorColor
        }
    }
    
    //default is 120.0. After maximum limit is reached, tokens starts scrolling vertically
    open var maximumHeight: CGFloat = 120.0 {
        didSet {
            _tokenField.maximumHeight = maximumHeight
        }
    }
    
    //default is UIColor.grayColor()
    open var cursorColor: UIColor = UIColor.gray {
        didSet {
            _updateTokenField()
        }
    }
    
    //default is 10.0. Horizontal padding of title
    open var paddingX: CGFloat = 10.0 {
        didSet {
            if (oldValue != paddingX) {
                _updateTokenField()
            }
        }
    }
    
    //default is 2.0. Vertical padding of title
    open var paddingY: CGFloat = 2.0 {
        didSet {
            if (oldValue != paddingY) {
                _updateTokenField()
            }
        }
    }
    
    //default is 5.0. Horizontal margin between tokens
    open var marginX: CGFloat = 5.0 {
        didSet {
            if (oldValue != marginX) {
                _updateTokenField()
            }
        }
    }
    
    //default is 5.0. Vertical margin between tokens
    open var marginY: CGFloat = 5.0 {
        didSet {
            if (oldValue != marginY) {
                _updateTokenField()
            }
        }
    }
    
    //default is 0. Horizontal buffer between prompt and content
    open var bufferX: CGFloat = 0.0 {
        didSet {
            if (oldValue != bufferX) {
                _updateTokenField()
            }
        }
    }
    
    //default is UIFont.systemFontOfSize(16)
    open var font: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            if (oldValue != font) {
                _updateTokenField()
            }
        }
    }
    
    //default is UIFont.systemFontOfSize(14)
    open var placeholderFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            if (oldValue != placeholderFont) {
                _updateTokenField()
            }
        }
    }
    
    //default is 50.0. Caret moves to new line if input width is less than this value
    open var minWidthForInput: CGFloat = 50.0 {
        didSet {
            if (oldValue != minWidthForInput) {
                _updateTokenField()
            }
        }
    }
    
    //default is ", ". Used to separate titles when untoknized
    open var separatorText: String = ", " {
        didSet {
            if (oldValue != separatorText) {
                _updateTokenField()
            }
        }
    }
    
    //An array of string values. Default values are "." and ",". Token is created with typed text, when user press any of the character mentioned in this Array
    open var tokenizingCharacters = [".", ","]
    
    //default is 0.25.
    open var animateDuration: TimeInterval = 0.1 {
        didSet {
            if (oldValue != animateDuration) {
                _updateTokenField()
            }
        }
    }
    
    //default is true. When resignFirstResponder is called tokens are removed and description is displayed.
    open var removesTokensOnEndEditing: Bool = true {
        didSet {
            if (oldValue != removesTokensOnEndEditing) {
                _updateTokenField()
            }
        }
    }
    
    //default is "selections"
    open var descriptionText: String = "selections" {
        didSet {
            if (oldValue != descriptionText) {
                _updateTokenField()
            }
        }
    }
    
    //set -1 for unlimited.
    open var maxTokenLimit: Int = -1 {
        didSet {
            if (oldValue != maxTokenLimit) {
                _updateTokenField()
            }
        }
    }
    
    //default is "To: "
    open var promptText: String = "To: " {
        didSet {
            if (oldValue != promptText) {
                _updateTokenField()
            }
        }
    }
    
    //default is true. If false, cannot be edited
    open var editable: Bool = true {
        didSet {
            _tokenField.isEnabled = editable
        }
    }
    
    //default is nil
    open var placeholder: String {
        get {
            return _tokenField.placeholder!
        }
        set {
            _tokenField.placeholder = newValue
        }
    }
    
    //default is UIColor.grayColor()
    open var promptColor: UIColor = UIColor.gray {
        didSet {
            _updateTokenField()
        }
    }
    
    //default is UIColor.grayColor()
    open var placeholderColor: UIColor = UIColor.gray {
        didSet {
            _updateTokenField()
        }
    }
    
    //default is .Rounded, creates rounded corner
    open var style: ETPTokenViewStyle = .rounded {
        didSet(newValue) {
            _updateTokenFieldLayout(style)
        }
    }
    
    //MARK: - Constructors
    
    /**
     Create and inialize ETPTokenView object
     
     - parameter frame: An object of type CGRect
     
     - returns: ETPTokenView object
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        _commonSetup()
    }
    
    /**
     Create and inialize ETPTokenView object from Interface builder
     
     - parameter aDecoder: An object of type NSCoder
     
     - returns: ETPTokenView object
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        _commonSetup()
    }
    
    //MARK: - Common Setup
    
    fileprivate func _commonSetup() {
        backgroundColor = UIColor.clear
        clipsToBounds = true
        _tokenField = ETPTokenField(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        _tokenField.textColor = UIColor.black
        _tokenField.isEnabled = true
        _tokenField.tokenFieldDelegate = self
        _tokenField.placeholder = ""
        _tokenField.autoresizingMask = [.flexibleWidth]
        _updateTokenField()
        addSubview(_tokenField)
        
        _indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        _indicator.hidesWhenStopped = true
        _indicator.stopAnimating()
        _indicator.color = activityIndicatorColor
        
        searchResultSize = CGSize(width: frame.width, height: searchResultHeight)
        _searchTableView.frame = CGRect(x: 0, y: frame.height, width: searchResultSize.width, height: searchResultSize.height)
        _searchTableView.delegate = self
        _searchTableView.dataSource = self
        
        _hideSearchResults()
        _intrinsicContentHeight = _tokenField.bounds.height
        invalidateIntrinsicContentSize()
    }
    
    //MARK: - Layout Changes
    
    override open func layoutSubviews() {
        _tokenField.updateLayout(false)
        _searchTableView.frame.size = CGSize(width: frame.width, height: searchResultSize.height)
    }
    
    override open var intrinsicContentSize : CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: _intrinsicContentHeight)
    }
    
    //MARK: - Public Methods
    
    //Changes the returnKeyType of ETPTokenField
    open func returnKeyType(type: UIReturnKeyType) {
        _tokenField.returnKeyType = type
    }
    
    open func tryTokenyze() {
        _ = _addTokenFromUntokenizedText(_tokenField);
    }
    
    //MARK: - Private Methods
    
    fileprivate func _updateTokenField() {
        _tokenField.parentView = self
    }
    
    fileprivate func _updateTokenFieldLayout(_ newValue: ETPTokenViewStyle) {
        switch (newValue) {
        case .rounded:
            _tokenField.borderStyle = .roundedRect
            backgroundColor = UIColor.clear
            
        case .squared:
            _tokenField.borderStyle = .bezel
            backgroundColor = _tokenField.backgroundColor
        }
    }
    
    fileprivate func _lastToken() -> ETPToken? {
        if _tokenField.tokens.count == 0 {
            return nil
        }
        return _tokenField.tokens.last
    }
    
    fileprivate func _removeToken(_ token: ETPToken, removingAll: Bool = false) {
        if token.sticky {return}
        if (!removingAll) {
            var shouldRemoveToken: Bool? = true
            
            if let shouldRemove = delegate?.tokenView?(self, shouldDeleteToken: token) {
                shouldRemoveToken = shouldRemove
            }
            if (shouldRemoveToken != true) {
                delegate?.tokenView?(self, didFailToDeleteToken: token)
                return
            }
            delegate?.tokenView?(self, willDeleteToken: token)
        }
        _tokenField.removeToken(token, removingAll: removingAll)
        if (!removingAll) {
            delegate?.tokenView?(self, didDeleteToken: token)
            _startSearchWithString("")
        }
    }
    
    fileprivate func _canAddMoreToken() -> Bool {
        if (maxTokenLimit != -1 && _tokenField.tokens.count >= maxTokenLimit) {
            _hideSearchResults()
            return false
        }
        return true
    }
    
    
    /**
     Returns an Array of ETPToken objects
     
     - returns: Array of ETPToken objects
     */
    open func tokens () -> Array<ETPToken>? {
        return _tokenField.tokens
    }
    
    //MARK: - Add Token
    
    /**
     Creates ETPToken from input text, when user press keyboard "Done" button
     
     - parameter tokenField: Field to add in
     
     - returns: Boolean if token is added
     */
    fileprivate func _addTokenFromUntokenizedText(_ tokenField: ETPTokenField) -> Bool {
        if (shouldAddTokenFromTextInput && tokenField.text != nil && tokenField.text != ETPTextEmpty) {
            let trimmedString = tokenField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            addTokenWithTitle(trimmedString)
            _hideSearchResults()
            return true
        }
        return false
    }
    
    /**
     Creates and add a new ETPToken object
     
     - parameter title:       Title of token
     - parameter tokenObject: Any custom object
     
     - returns: ETPToken object
     */
    @discardableResult open func addTokenWithTitle(_ title: String, tokenObject: AnyObject? = nil) -> ETPToken? {
        let token = ETPToken(title: title, object: tokenObject)
        token.tokenBackgroundColor = tokenBackgroundColor
        return addToken(token)
    }
    
    
    /**
     Creates and add a new ETPToken object
     
     - parameter token: ETPToken object
     
     - returns: ETPToken object
     */
    @discardableResult open func addToken(_ token: ETPToken) -> ETPToken? {
        if (!_canAddMoreToken()) {
            return nil
        }
        
        var shouldAddToken: Bool? = true
        if let shouldAdd = delegate?.tokenView?(self, shouldAddToken: token) {
            shouldAddToken = shouldAdd
        }
        
        if (shouldAddToken != true) {
            delegate?.tokenView?(self, didFailToAdd: token)
            return nil
        }
        
        delegate?.tokenView?(self, willAddToken: token)
        var addedToken: ETPToken?
        if let updatedToken = delegate?.tokenView?(self, shouldChangeAppearanceForToken: token) {
            addedToken = _tokenField.addToken(updatedToken)
            
        } else {
            addedToken = _tokenField.addToken(token)
        }
        
        delegate?.tokenView?(self, didAddToken: addedToken!)
        return addedToken
    }
    
    
    //MARK: - Delete Token
    
    /**
     Deletes an already added ETPToken object
     
     - parameter token: ETPToken object
     */
    open func deleteToken(_ token: ETPToken) {
        _removeToken(token)
    }
    
    /**
     Searches for ETPToken object and deletes
     
     - parameter object: Custom object
     */
    open func deleteTokenWithObject(_ object: AnyObject?) {
        if object == nil {return}
        for token in _tokenField.tokens {
            if (token.object!.isEqual(object)) {
                _removeToken(token)
                break
            }
        }
    }
    
    /**
     Deletes all added tokens. This doesn't delete sticky token
     */
    open func deleteAllTokens() {
        if (_tokenField.tokens.count == 0) {return}
        var shouldDeleteAllTokens: Bool? = true
        
        if let shouldRemoveAll = delegate?.tokenViewShouldDeleteAllToken?(self) {
            shouldDeleteAllTokens = shouldRemoveAll
        }
        
        if (shouldDeleteAllTokens != true) {
            delegate?.tokenViewDidFailToDeleteAllTokens?(self)
            return
        }
        
        delegate?.tokenViewWillDeleteAllToken?(self)
        for token in _tokenField.tokens {_removeToken(token, removingAll: true)}
        _tokenField.updateLayout()
        delegate?.tokenViewDidDeleteAllToken?(self)
        
        if (_showingSearchResult) {
            _startSearchWithString(_lastSearchString)
        }
    }
    
    /**
     Deletes last added ETPToken object
     */
    open func deleteLastToken() {
        let token: ETPToken? = _lastToken()
        if token != nil {
            _removeToken(token!)
        }
    }
    
    /**
     Deletes selected ETPToken object
     */
    open func deleteSelectedToken() {
        let token: ETPToken? = selectedToken()
        if (token != nil) {
            _removeToken(token!)
        }
    }
    
    /**
     Returns Selected ETPToken object
     
     - returns: ETPToken object
     */
    open func selectedToken() -> ETPToken? {
        return _tokenField.selectedToken
    }
    
    
    //MARK: - ETPTokenFieldDelegates
    
    func tokenFieldDidBeginEditing(_ tokenField: ETPTokenField) {
        delegate?.tokenViewDidBeginEditing?(self)
        tokenField.tokenize()
        if (minimumCharactersToSearch == 0) {
            _startSearchWithString("")
        }
    }
    
    func tokenFieldDidEndEditing(_ tokenField: ETPTokenField) {
        delegate?.tokenViewDidEndEditing?(self)
        if (shouldUntokenizeOnEndEditing) {
            tokenField.untokenize()
        } else {
            tokenField.scrollToTop()
        }
        _hideSearchResults()
    }
    
    open override var isFirstResponder : Bool {
        return _tokenField.isFirstResponder
    }
    
    override open func becomeFirstResponder() -> Bool {
        return _tokenField.becomeFirstResponder()
    }
    
    @discardableResult override open func resignFirstResponder() -> Bool {
        if (!_addTokenFromUntokenizedText(_tokenField)) {
            _tokenField.resignFirstResponder()
        }
        return false
    }
    
    //MARK: - Search
    
    /**
     Triggers the search after user input text
     
     - parameter string: Search keyword
     */
    fileprivate func _startSearchWithString(_ string: String) {
        if (!_canAddMoreToken()) {
            return
        }
        _showEmptyResults()
        _showActivityIndicator()
        
        let trimmedSearchString = string.trimmingCharacters(in: CharacterSet.whitespaces)
        delegate?.tokenView(self, performSearchWithString:trimmedSearchString, completion: { (results) -> Void in
            self._hideActivityIndicator()
            if (results.count > 0) {
                self._displayData(results)
            }
        })
    }
    
    fileprivate func _displayData(_ results: Array<AnyObject>) {
        _resultArray = _filteredSearchResults(results)
        _searchTableView.reloadData()
        _showSearchResults()
    }
    
    fileprivate func _showEmptyResults() {
        _resultArray.removeAll(keepingCapacity: false)
        _searchTableView.reloadData()
        _showSearchResults()
    }
    
    fileprivate func _showSearchResults() {
        guard !_showingSearchResult else {return}
        _showingSearchResult = true
        addSubview(_searchTableView)
        let tokenFieldHeight = _tokenField.frame.height
        _searchTableView.isHidden = false
        _changeHeight(tokenFieldHeight)
        delegate?.tokenViewDidShowSearchResults?(self)
    }
    
    fileprivate func _hideSearchResults() {
        guard _showingSearchResult else {return}
        _showingSearchResult = false
        let searchTableView = self._searchTableView
        _changeHeight(_tokenField.frame.height) {
            searchTableView.isHidden = true
            searchTableView.removeFromSuperview()
        }
        delegate?.tokenViewDidHideSearchResults?(self)
    }
    
    fileprivate func _repositionSearchResults(_ height: CGFloat) {
        if (!_showingSearchResult) {
            return
        }
        _searchTableView.frame.origin = CGPoint(x: 0, y: height)
    }
    
    fileprivate func _filteredSearchResults(_ results: Array <AnyObject>) -> Array <AnyObject> {
        var filteredResults: Array<AnyObject> = Array()
        
        for object: AnyObject in results {
            // Check duplicates in array
            var shouldAdd = !(filteredResults as NSArray).contains(object)
            
            if (shouldAdd) {
                if (!shouldDisplayAlreadyTokenized && _tokenField.tokens.count > 0) {
                    
                    // Search if already tokenized
                    for token: ETPToken in _tokenField.tokens {
                        if (object.isEqual(token.object)) {
                            shouldAdd = false
                            break
                        }
                    }
                }
                
                if (shouldAdd) {
                    filteredResults.append(object)
                }
            }
        }
        
        if (shouldSortResultsAlphabatically) {
            return filteredResults.sorted(by: { s1, s2 in return self._sortStringForObject(s1) < self._sortStringForObject(s2) })
        }
        return filteredResults
    }
    
    fileprivate func _sortStringForObject(_ object: AnyObject) -> String {
        if let title = delegate?.tokenView?(self, titleForToken: object) {
            return title
        } else {
            return (delegate?.tokenView(self, displayTitleForObject: object))!
        }
    }
    
    fileprivate func _showActivityIndicator() {
        _indicator.startAnimating()
        _searchTableView.tableHeaderView = _indicator
    }
    
    fileprivate func _hideActivityIndicator() {
        _indicator.stopAnimating()
        _searchTableView.tableHeaderView = nil
    }
    
    fileprivate func _changeHeight(_ tokenFieldHeight: CGFloat, completion: (() -> Void)? = nil) {
        let fullHeight = tokenFieldHeight + (_showingSearchResult ? searchResultHeight : 0.0)
        delegate?.tokenView?(self, willChangeFrameWithX: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: fullHeight)
        self._repositionSearchResults(tokenFieldHeight)
        
        UIView.animate(
            withDuration: animateDuration,
            animations: {
                self._tokenField.frame.size.height = tokenFieldHeight
                self.frame.size.height = fullHeight
                self._intrinsicContentHeight = fullHeight
                self.invalidateIntrinsicContentSize()
                self.superview?.layoutIfNeeded()
        },
            completion: {completed in
                completion?()
                if (completed) {
                    self.delegate?.tokenView?(self, didChangeFrameWithX: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: fullHeight)
                }
        })
    }
    
}

//MARK: - Extension ETPTokenFieldDelegate

extension ETPTokenView : ETPTokenFieldDelegate {
    func tokenFieldDidSelectToken(_ token: ETPToken) {
        delegate?.tokenView?(self, didSelectToken: token)
    }
    
    func tokenFieldShouldChangeHeight(_ height: CGFloat) {
        _changeHeight(height)
    }
}


//MARK: - Extension UITextFieldDelegate

extension ETPTokenView : UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //If backspace is pressed
        if (_tokenField.tokens.count > 0 && _tokenField.text == ETPTextEmpty && string.isEmpty == true && shouldDeleteTokenOnBackspace) {
            if (_lastToken() != nil) {
                if (selectedToken() != nil) {
                    deleteSelectedToken()
                } else {
                    _tokenField.selectToken(_lastToken()!)
                }
            }
            return false
        }
        
        //Prevent removing ETPTextEmpty
        if (string.isEmpty == true && _tokenField.text == ETPTextEmpty) {
            return false
        }
        
        var searchString: String
        let olderText = _tokenField.text
        var olderTextTrimmed = olderText!
        //remove the empty text marker from the beginning of the string
        if (olderText?.characters.first == ETPTextEmpty.characters.first) {
            olderTextTrimmed = olderText!.substring(from: olderText!.characters.index(olderText!.startIndex, offsetBy: 1))
        }
        
        //Check if character is removed at some index
        //Remove character at that index
        if (string.isEmpty) {
            let first: String = olderText!.substring(to: olderText!.characters.index(olderText!.startIndex, offsetBy: range.location)) as String
            let second: String = olderText!.substring(from: olderText!.characters.index(olderText!.startIndex, offsetBy: range.location+1)) as String
            searchString = first + second
            searchString = searchString.trimmingCharacters(in: CharacterSet.whitespaces)
            
        } else {
            //New character added
            if (tokenizingCharacters.contains(string)) {
                if (olderText != ETPTextEmpty && olderTextTrimmed != "") {
                    addTokenWithTitle(olderTextTrimmed, tokenObject: nil)
                    _hideSearchResults()
                }
                return false
            }
            searchString = (olderText! as NSString).replacingCharacters(in: range, with: string)
            if (searchString.characters.first == ETPTextEmpty.characters.first) {
                searchString = searchString.substring(from: searchString.characters.index(searchString.startIndex, offsetBy: 1))
            }
        }
        
        //Allow all other characters
        if (searchString.characters.count >= minimumCharactersToSearch && searchString != "\n") {
            _lastSearchString = searchString
            _startSearchWithString(_lastSearchString)
        } else {
            _hideSearchResults()
        }
        
        _tokenField.scrollViewScrollToEnd()
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}

//MARK: - Extension UITableViewDelegate

extension ETPTokenView : UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tokenView?(self, didSelectRowAtIndexPath: indexPath)
        let object: AnyObject = _resultArray[(indexPath as NSIndexPath).row]
        var title: String
        
        if let _title = delegate?.tokenView?(self, titleForToken: object) {
            title = _title
        } else {
            title = (delegate?.tokenView(self, displayTitleForObject: object))!
        }
        
        addToken(ETPToken(title: title, object: object))
        
        if (shouldHideSearchResultsOnSelect) {
            _hideSearchResults()
            
        } else if (!shouldDisplayAlreadyTokenized) {
            _resultArray.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        }
    }
}

//MARK: - Extension UITableViewDataSource

extension ETPTokenView : UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _resultArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ETPSearchTableCell"
        var cell: UITableViewCell
        if let _cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)  {
            cell = _cell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        if let detail = delegate?.tokenView?(self, displayDetailForObject: _resultArray[(indexPath as NSIndexPath).row]) {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
            cell.detailTextLabel?.text = detail
        }
        
        let title = delegate?.tokenView(self, displayTitleForObject: _resultArray[(indexPath as NSIndexPath).row])
        cell.textLabel?.text = title ?? "No Title"
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        return cell
    }
}

