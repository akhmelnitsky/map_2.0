function CategoryFilter() {
    this.FilterItems = [];
    
    /*Добавить категорию в фильтр*/
    this.TurnOnCategoryFilterItem = function (FilterItemName) {
        var filter_id=this.GetItemByName(FilterItemName);
        this.FilterItems[filter_id].active=1;
    };

    /*Убрать категорию из фильтра*/
    this.TurnOffCategoryFilterItem = function (FilterItemName) {
        var filter_id=this.GetItemByName(FilterItemName);
       this.FilterItems[filter_id].active=0;
    };
    
    /*Загрузить доступные категрии, используем closure*/
    this.LoadCategoryFilter = function (url) {
        var obj=this;
        $.getJSON(url).done(function (data_json) {
            obj.FilterItems = data_json;
            obj.CreateCategoryFilterDOM();
        });
    };

    this.GetItemByName = function (FilterItemName) {
        var res=-1;
        for (var i = 0; i < this.FilterItems.length; i++) {
            if (this.FilterItems[i].id===FilterItemName) {
                res=i;
            };
        };
        return res;
    };

   /*Переключает категорию фильтра между доступной и недостуной*/
    this.ToggleCategoryFilterItem = function (FilterItemName) {
        var filter_id=this.GetItemByName(FilterItemName);
        if (this.FilterItems[filter_id].active===0) {
            this.TurnOnCategoryFilterItem(FilterItemName);
        } else {
            this.TurnOffCategoryFilterItem(FilterItemName);
        };
    };

    /*Создает DOM для загруженного фильтра категорий*/
    this.CreateCategoryFilterDOM =function () {
        var filters = document.getElementById('filters');
       for (var i = 0; i < this.FilterItems.length; i++) {
            // Create an an input checkbox and label inside.
            var toolbar_item = filters.appendChild(document.createElement('li'));
            //var item_image = item.appendChild(document.createElement('i'));
            //var label = item.appendChild(document.createElement('label'));
            //var pointType = $.parseJSON(pointTypes[i]);
            toolbar_item.role = 'button';
            toolbar_item.id = this.FilterItems[i].id;
            toolbar_item.setAttribute('data-category',this.FilterItems[i].id);
            //toolbar_item.classList.add(pointTypes[i].id);
            //toolbar_item.innerHTML = pointTypes[i].name;
            var toolbar_item_image = toolbar_item.appendChild(document.createElement('img'));
            toolbar_item_image.src = this.FilterItems[i].pic;
            toolbar_item_image.classList.add("toolbar-item-image");
            //checkbox.checked = true;
            // create a label to the right of the checkbox with explanatory text
            //toolbar_item.setAttribute('for', pointTypes[i].id);
            // Whenever a person clicks on this checkbox, call the update().
            toolbar_item.addEventListener('click', ClickCategoryFilterItem);
            //checkboxes.push(checkbox);
        };
    };

    /*Применяет фильтр к карте*/
    this.ApplyCategoryFilterToMap =function () {
        var enabled = {};
        //console.log(filter_array);
        for (var i = 0; i < this.FilterItems.length; i++) {
            if (this.FilterItems[i].active===1) {
                enabled[this.FilterItems[i].id]=true;
            };
        };
        featureLayer.setFilter(function(feature) {
           return (feature.properties['type'] in enabled); 
        });
    };  
};

function ClickCategoryFilterItem() {
    categoryFilter.ToggleCategoryFilterItem(this.getAttribute('data-category'));
    categoryFilter.ApplyCategoryFilterToMap();
}

var categoryFilter = new CategoryFilter ();
categoryFilter.LoadCategoryFilter('/pointTypes');
//categoryFilter.ApplyCategoryFilterToMap();
